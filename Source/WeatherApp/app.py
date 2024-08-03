from os import environ
import sys
import subprocess
import os

def install_packages():
    try:
        pip_executable = os.path.join('antenv', 'bin', 'pip') if os.name != 'nt' else os.path.join('antenv', 'Scripts', 'pip')
        subprocess.check_call([pip_executable, 'install', '--upgrade', 'pip', 'setuptools'])
        print("pip and setuptools upgraded successfully.")
        subprocess.check_call([pip_executable, 'install', 'pipreqs'])
        print("pipreqs installed successfully.")
        subprocess.run(['antenv/bin/pipreqs', '.'])
        subprocess.run(['sed','-i','/azure_storage/d', 'requirements.txt'])      
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--upgrade', 'pip'])
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--upgrade', 'setuptools'])
        subprocess.check_call([pip_executable,'install','azure.identity'])
        subprocess.check_call([pip_executable,'install','azure.keyvault.secrets'])
        subprocess.check_call([pip_executable,'install','azure.servicebus'])
        subprocess.check_call([pip_executable,'install','pyodbc'])
        subprocess.check_call([pip_executable,'install','email_validator'])
        subprocess.check_call([sys.executable, '-m','pip','install','-r','requirements.txt'])
        print("Required packages installed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while installing packages: {e}")
        raise

def update_env_file(pairs):
    dotenv_path = find_dotenv()
    if dotenv_path:
        load_dotenv(dotenv_path)
        for key, value in pairs:
            set_key(dotenv_path, key, value)
            print(f"Updated {key} to {value} in {dotenv_path}")
    else:
        print(".env file not found")

if __name__ == '__main__':
    if (os.name=='posix'):
        install_packages()
    if (os.name=='nt'):
        venv_path = "antenv"
        subprocess.run([sys.executable, "-m", "venv", venv_path])
        activation_script = os.path.join(venv_path, "bin", "activate")
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pipreqs'])
        subprocess.run(['pipreqs', os.path.abspath(os.getcwd())])
        subprocess.check_call(['pip', 'install', 'mysqlclient'])
        subprocess.check_call(['pip', 'install', 'azure.identity'])
        subprocess.check_call(['pip', 'install', 'azure.keyvault.secrets'])
        subprocess.check_call(['pip', 'install', 'azure.servicebus'])
        subprocess.check_call(['pip', 'install', 'python-dotenv'])
        subprocess.check_call(['pip', 'install', 'flask_sqlalchemy'])
        subprocess.check_call(['pip', 'install', 'pyodbc'])
        subprocess.check_call(['pip', 'install', 'flask_login'])
        subprocess.check_call(['pip', 'install', 'email_validator'])
        subprocess.check_call(['powershell', f'{sys.executable} -m pip install --upgrade pip'], shell=True)
        subprocess.check_call(['powershell', f'{sys.executable} -m pip install --upgrade setuptools'], shell=True)
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'])
    import argparse
    from dotenv import load_dotenv, set_key, find_dotenv
    parser = argparse.ArgumentParser(description='Update .env file with command-line arguments.')
    parser.add_argument('--pairs', nargs='+', required=False, help='Key-value pairs to update in the .env file (e.g., KEY1=VALUE1 KEY2=VALUE2)')
    args = parser.parse_args()
    if args.pairs:
        pairs = [pair.split('=') for pair in args.pairs]
        update_env_file(pairs)
    from flask_auth import app
    app.run(host='0.0.0.0',port=8000,debug=True,use_reloader=False)
    # app.run(port=8000)