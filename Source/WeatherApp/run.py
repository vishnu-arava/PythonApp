from os import environ
import sys
import subprocess
import os

#def install_python3_venv():
#    try:
#        subprocess.check_call(['sudo', 'apt-get', 'update'])
#        subprocess.check_call(['sudo', 'apt-get', 'install', '-y', 'python3*-venv'])
#        print("python3.10-venv installed successfully.")
#    except subprocess.CalledProcessError as e:
#        print(f"An error occurred while installing python3.10-venv: {e}")
#        raise

def create_virtualenv(venv_path):
    try:

        subprocess.check_call([sys.executable, '-m', 'venv', venv_path])
        print(f"Virtual environment created at {venv_path}.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while creating the virtual environment: {e}")
        raise
def install_packages(venv_path, requirements_file):
    try:
        pip_executable = os.path.join(venv_path, 'bin', 'pip') if os.name != 'nt' else os.path.join(venv_path, 'Scripts', 'pip')

        subprocess.check_call([pip_executable, 'install', '--upgrade', 'pip', 'setuptools'])
        print("pip and setuptools upgraded successfully.")

        subprocess.check_call([pip_executable, 'install', 'pipreqs'])
        print("pipreqs installed successfully.")

        #subprocess.run([os.path.join(venv_path, 'bin', 'pipreqs'), os.path.abspath(os.getcwd())])

        #subprocess.check_call(['sudo', 'apt-get', 'install', '-y', 'pkg-config'])
        #subprocess.check_call(['sudo', 'apt-get', 'install', '-y', 'libmysqlclient-dev'])
        #subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--upgrade', 'pip'])
        #subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--upgrade', 'setuptools'])

        #subprocess.check_call([sys.executable, '-m','pip','install','-r',requirements_file])
        print("Required packages installed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while installing packages: {e}")
        raise

if __name__ == '__main__':
    #if (os.name=='posix'):
        #venv_path = "./venv"
        #requirements_file = 'requirements.txt'
        #install_python3_venv()
        #create_virtualenv(venv_path)
        #install_packages(venv_path, requirements_file)
    if (os.name=='nt'):
        venv_path = "venv"
        subprocess.run([sys.executable, "-m", "venv", venv_path])
        activation_script = os.path.join(venv_path, "bin", "activate")
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pipreqs'])
        subprocess.run(['pipreqs', os.path.abspath(os.getcwd())])

        subprocess.check_call(['pip', 'install', 'mysqlclient'])

        # Upgrade pip
        subprocess.check_call(['powershell', f'{sys.executable} -m pip install --upgrade pip'], shell=True)

        # Upgrade setuptools
        subprocess.check_call(['powershell', f'{sys.executable} -m pip install --upgrade setuptools'], shell=True)
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'])
    from flask_auth import app
    app.run(host='0.0.0.0',port=5000,debug=True,use_reloader=False)