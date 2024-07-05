from os import environ
import sys
import subprocess
import os

def install_packages():
    try:
        pip_executable = os.path.join('venv', 'bin', 'pip') if os.name != 'nt' else os.path.join('venv', 'Scripts', 'pip')
        subprocess.check_call([pip_executable, 'install', '--upgrade', 'pip', 'setuptools'])
        print("pip and setuptools upgraded successfully.")
        subprocess.check_call([pip_executable, 'install', 'pipreqs'])
        print("pipreqs installed successfully.")
        subprocess.run(['venv/bin/pipreqs', '.'])
        subprocess.run(['sed','-i','/azure_storage/d', 'requirements.txt'])      
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--upgrade', 'pip'])
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--upgrade', 'setuptools'])
        subprocess.check_call([pip_executable,'install','azure.identity'])
        subprocess.check_call([pip_executable,'install','azure.keyvault.secrets'])
        subprocess.check_call([pip_executable,'install','pyodbc'])
        subprocess.check_call([sys.executable, '-m','pip','install','-r','requirements.txt'])
        print("Required packages installed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while installing packages: {e}")
        raise

if __name__ == '__main__':
    if (os.name=='posix'):
        install_packages()
    if (os.name=='nt'):
        venv_path = "venv"
        subprocess.run([sys.executable, "-m", "venv", venv_path])
        activation_script = os.path.join(venv_path, "bin", "activate")
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pipreqs'])
        subprocess.run(['pipreqs', os.path.abspath(os.getcwd())])
        subprocess.check_call(['pip', 'install', 'mysqlclient'])
        subprocess.check_call(['powershell', f'{sys.executable} -m pip install --upgrade pip'], shell=True)
        subprocess.check_call(['powershell', f'{sys.executable} -m pip install --upgrade setuptools'], shell=True)
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'])
    from flask_auth import app
    app.run(host='0.0.0.0',port=5000,debug=True,use_reloader=False)