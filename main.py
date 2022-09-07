from _config import *
from flask import Flask, request, render_template, jsonify
import psycopg2


try:
    conn = psycopg2.connect(host=db_host, port=db_port, user=db_user, password=db_pass, database=db_dbname)
    mycursor = conn.cursor()
    print("connected")
except:
    print ("I am unable to connect to the database")
    exit()


###### Function Definition ######

def updateVacancy(updtype, vacid):
    add = 50
    qry = ''
    if (updtype == 'up' or updtype == 'down'):
        if updtype == 'down':
            add = add * (-1)
        if vacid.isnumeric():
            qry = 'INSERT INTO mi.t_vacancy_additional_rank(vacancy_id, additional_rank, mod_date) VALUES (%s, %s, NOW());' % (vacid, add)
            mycursor.execute(qry)
            conn.commit()

    return jsonify({'Vacancy ID': vacid,
                    'Update Type': updtype,
                    'Update Value': add,
                    'Executed Query': qry})


def updateClient(ccid, fieldname, fieldvalue):
    qry = ''
    if ccid.isnumeric():
        if fieldname == 'client_type' or fieldname == 'client_probability' or fieldname == 'client_recruitment' or fieldname == 'client_relations':
            qry = 'INSERT INTO mi.t_client_attributes (client_corporation_id, %s, mod_date) VALUES (%s, \'%s\', NOW()) ON CONFLICT (client_corporation_id) DO UPDATE SET %s = \'%s\', mod_date = NOW();' % (fieldname, ccid, fieldvalue, fieldname, fieldvalue)
            mycursor.execute(qry)
            conn.commit()

    return jsonify({'Client Corp ID': ccid,
                    'FieldName': fieldname,
                    'FieldValue': fieldvalue,
                    'Executed Query': qry})


###### Flask App Definition #######

app = Flask(__name__, static_folder='templates/css')

### Flask App Pages ###

@app.route('/')
def mainpage():
    mycursor.execute("SELECT * FROM mi.v_vacancy_priority_rank ORDER BY sum_rank DESC")
    data = mycursor.fetchall()
    return render_template('index.html', data=data)


@app.route('/clientatr')
def clientatr():
    mycursor.execute("SELECT * FROM mi.v_client_attributes")
    data = mycursor.fetchall()
    return render_template('clientatr.html', data=data)


### Flask Api ###

@app.route('/api/<updtype>/<vacid>')
def updateVacancyApi(updtype, vacid):
    resp = updateVacancy(updtype, vacid)
    return resp


@app.route('/api/<ccid>/<fieldname>/<fieldvalue>')
def updateClientApi(ccid, fieldname, fieldvalue):
    resp = updateClient(ccid, fieldname, fieldvalue)
    return resp


### Run App ###

if __name__ == '__main__':
    app.run(debug=True)