# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from jupyter_core.paths import jupyter_data_dir
import subprocess
import os
import errno
import stat

c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.ResourceUseDisplay.track_cpu_percent = True

# https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash = False

c.ServerProxy.servers = {}
if os.getenv('MLFLOW_ENABLED', 'false') == 'true':
    c.ServerProxy.servers['mlflow'] = {
            'command': ['/bin/bash', '-c', '/opt/tools/bin/start-mlflow.sh', '{port}'],
            'port': 5000,
            'absolute_url': False,
            'timeout': 30,
            'launcher_entry': {
                'title': "MLflow",
                'icon_path': '/opt/tools/logos/mlflow.svg',
        }
    }

if os.getenv('AIRFLOW_ENABLED', 'false') == 'true':
    c.ServerProxy.servers['airflow'] = {
        'command': ['/bin/bash', '-c', '/opt/tools/bin/start-airflow.sh', '{base_url}', '{port}'],
        'port': 6000,
        'absolute_url': True,
        'timeout': 600,
        'launcher_entry': {
            'title': "Airflow",
            'icon_path': '/opt/tools/logos/airflow.svg',
        }
    }
if os.getenv('VS_CODE_ENABLED', 'false') == 'true':
    c.ServerProxy.servers['vscode'] = {
        'command': ['/bin/bash', '-c', '/opt/tools/bin/start-vscode.sh', '{port}'],
        'port': 7000,
        'absolute_url': False,
        'timeout': 30,
        'launcher_entry': {
            'title': "VSCode",
            'icon_path': '/opt/tools/logos/vs-code.svg',
        }
    }

c.LauncherShortcuts.shortcuts = {
    'spark': {
        'title': 'Spark UI',
        'target': f'https://{os.getenv("LAB_DOMAIN", "localhost")}/user/{os.environ["USER"]}/proxy/4040/jobs/',
        'icon_path': '/opt/tools/logos/spark.svg'
    }
}

if os.getenv('KEDRO_ENABLED', 'false') == 'true':
    c.LauncherShortcuts.shortcuts = {
        'kedro-viz-short': {
            'title': 'Kedro Viz - proxy',
            'target': f'https://{os.getenv("LAB_DOMAIN", "localhost")}/user/{os.environ["USER"]}/proxy/4141/',
            'icon_path': '/opt/tools/logos/kedro.svg'
        }
    }

# Generate a self-signed certificate
if 'GEN_CERT' in os.environ:
    dir_name = jupyter_data_dir()
    pem_file = os.path.join(dir_name, 'notebook.pem')
    try:
        os.makedirs(dir_name)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(dir_name):
            pass
        else:
            raise

    # Generate an openssl.cnf file to set the distinguished name
    cnf_file = os.path.join(os.getenv('CONDA_DIR', '/usr/lib'), 'ssl', 'openssl.cnf')
    if not os.path.isfile(cnf_file):
        with open(cnf_file, 'w') as fh:
            fh.write('''\
[req]
distinguished_name = req_distinguished_name
[req_distinguished_name]
''')

    # Generate a certificate if one doesn't exist on disk
    subprocess.check_call(['openssl', 'req', '-new',
                           '-newkey', 'rsa:2048',
                           '-days', '365',
                           '-nodes', '-x509',
                           '-subj', '/C=XX/ST=XX/L=XX/O=generated/CN=generated',
                           '-keyout', pem_file,
                           '-out', pem_file])
    # Restrict access to the file
    os.chmod(pem_file, stat.S_IRUSR | stat.S_IWUSR)
    c.NotebookApp.certfile = pem_file

# Change default umask for all subprocesses of the notebook server if set in
# the environment
if 'NB_UMASK' in os.environ:
    os.umask(int(os.environ['NB_UMASK'], 8))