import os
from flask import Flask

from secrets_manager import get_secret

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello world!'


@app.route('/spleet/<key>')
def spleet_file(key):
    print('got a request')
    thiskey = str(key)

    currentworkingdirectory = os.getcwd()
    filesdir = 'files'
    fileabsolutepath = os.path.abspath(currentworkingdirectory+'/'+filesdir+'/'+thiskey)
    print(fileabsolutepath)


    print('gonna spleet now')
    fileabpath = os.path.abspath("./files/"+thiskey);
    print(fileabpath);
    spleetercmd = subprocess.run(["/root/miniconda3/bin/spleeter", "separate", "-o", "output", fileabpath])
    print(spleetercmd.stdout)
    # requests.get('http://spleeternode:3000/spleetcomplete/'+thiskey).content
    return 'success'

if __name__ == '__main__':
    app.run(host='0.0.0.0')
