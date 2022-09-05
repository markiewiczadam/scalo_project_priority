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


###### Flask App Definition #######

app = Flask(__name__, static_folder='templates/css')

@app.route('/')
def v_timestamp():
    msg = 'Test Message!'
    mycursor.execute("SELECT * FROM mi.v_vacancy_priority_rank ORDER BY sum_rank DESC")
    data = mycursor.fetchall()
    return render_template('vacancies2.html', data=data)


@app.route('/api/<updtype>/<vacid>')
def update(updtype, vacid):
    resp = updateVacancy(updtype, vacid)
    return resp


### Run App ###

if __name__ == '__main__':
    app.run(debug=True)