from _config import *
from flask import Flask, render_template, jsonify, request
import psycopg2


###### Define Admin User List #######

adminUserList = ('adam.markiewicz@scalosoft.com')


###### Define DB Connection #######

try:
    conn = psycopg2.connect(host=db_host, port=db_port, user=db_user, password=db_pass, database=db_dbname)
    mycursor = conn.cursor()
except:
    exit()


###### Define Flask App #######

app = Flask(__name__, static_folder='templates/css')


### Define App Pages ###

@app.route('/')
def mainpage():
    usrname = request.headers.get('X-MS-CLIENT-PRINCIPAL-NAME')
    if usrname != None and usrname in adminUserList:
        usrlvl = 'admin'
    else:
        usrlvl = 'read only'

    mycursor.execute("SELECT * FROM mi.v_vacancy_priority_v2")
    data = mycursor.fetchall()
    return render_template('index.html', data=data, usrlvl=usrlvl, usrname=usrname)


@app.route('/clientatr')
def clientatr():
    mycursor.execute("SELECT * FROM mi.v_client_attributes")
    data = mycursor.fetchall()
    return render_template('clientatr.html', data=data)



### Run App ###

if __name__ == '__main__':
    app.run(debug=True)