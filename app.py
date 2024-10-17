import shutil
from flask import Flask, request, jsonify, send_file
from flask_mysqldb import MySQL
from flask_cors import CORS
import re
from smtplib import SMTP
from email.message import EmailMessage
import random
import os
from werkzeug.utils import secure_filename
from datetime import datetime
import json
import firebase_admin
from firebase_admin import credentials, messaging

app = Flask(__name__)
CORS(app)

app.config["MYSQL_HOST"] = "localhost"
app.config["MYSQL_USER"] = "root"
app.config["MYSQL_PASSWORD"] = "3122005x"
app.config["MYSQL_DB"] = "chatapp"

mysql = MySQL(app)


cred = credentials.Certificate("chatappflut-1d190-firebase-adminsdk-eo1bo-7b1ffeb2c1.json")
firebase_admin.initialize_app(cred)

def is_invalid_email(email):
    pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    if re.search(pattern, email):
        return True


def is_invalid_password(password):
    if (len(password) >= 8 and re.search(r'[a-zA-Z]', password) and re.search(r'[0-9]', password)):
        return True

@app.route('/email_SMTP/<email>')
def email_SMTP(email):
    otp = ""
    for _ in range(6):
        otp += str(random.randint(0, 9))

    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE users SET OTP = %s WHERE email = %s", (otp, email))
    mysql.connection.commit()
    cursor.close()

    server = SMTP("smtp.gmail.com", 587)
    server.starttls()

    from_mail = "appoaep@gmail.com"
    to_mail = email
    server.login(from_mail, "kvab rzkv toer idmn")

    msg = EmailMessage()
    msg["Subject"] = "OTP Verification"
    msg["From"] = from_mail
    msg["To"] = to_mail
    msg.set_content(f"OTP Code {otp}")

    server.send_message(msg)

    return jsonify({
        "message": "Verification code sent successfully"
    })


@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    username = data['username']
    email = data['email']
    password = data['password']
    created_at = data['created_at']
    token = data['token']
    space_check = True
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM users WHERE username = %s OR email = %s", (username,email))
    user_info = cursor.fetchone()
    for i in username:
        if (i == " "):
            space_check = False
    if (space_check == True):
        if (username != ""):
            if (is_invalid_email(email)):
                if (is_invalid_password(password)):
                    if user_info is None:
                        cursor = mysql.connection.cursor()
                        cursor.execute("INSERT INTO users (username,email,password,profile_image,registration_time,status,bio,token) VALUES(%s,%s,%s,%s,%s,%s,%s,%s)", (username, email, password, "profile_image/3276535.png", created_at,created_at,"",token))
                        mysql.connection.commit()
                        email_SMTP(email)
                        cursor.close()
                        return jsonify({
                            "message": "Your registration has been successfully completed"
                        }), 200
                    else:
                        return jsonify({
                            "message": "Email or Username available"
                        }), 400
                else:
                    return jsonify({
                        "message": "Password must be at least one letter, one number and 8 characters."
                    }), 400
            else:
                return jsonify({
                    "message": "Email format is incorrect"
                }), 400
        else:
            return jsonify({
                "message": "Please fill out the name form"
            }), 400
    else:
        return jsonify({
            "message" : "There cannot be a space in the name"
        }), 400


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data['email']
    password = data['password']
    if (is_invalid_email(email)):
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT*FROM users WHERE email = %s AND password = %s",(email,password))
        user_info = cursor.fetchone()
        if (user_info):
            if (user_info[5] == "True"):
                return jsonify({
                    "message" : "Your login was successfully authenticated."
                }),200
            else:
                return jsonify({
                    "message" : "Please verify your OTP."
                }),400
        else:
            return jsonify({
                "message" : "Authentication failed. Please ensure your username and password are correct."
            }),400
    else:
        return jsonify({
            "message" : "Email format is incorrect"
        }),400


@app.route('/get_account_info', methods = ["GET"])
def get_username():
    data = request.args;
    email = data.get('email')
    password = data.get('password')
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM users WHERE email = %s AND password = %s",(email, password))
    user_info = cursor.fetchone()
    cursor.close()
    if (user_info):
        return jsonify({
            "username": user_info[1],

        }),200
    else:
        return jsonify({
            "username" : "invalid"
        }),400


@app.route('/verify_OTP', methods = ["POST"])
def verify_OTP():
    data = request.get_json()
    email = data['email']
    OTP = data['OTP']

    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM users WHERE email = %s", (email,))
    user_info = cursor.fetchone()
    if (user_info[5] == OTP):
        cursor.execute("UPDATE users SET OTP = %s WHERE email = %s", ("True", email))
        mysql.connection.commit()
        cursor.close()
        return jsonify({
            "message" : "Your OTP has been successfully verified."
        }),200
    else:
        return jsonify({
            "message" : "OTP verification failed. Please try again."
        }),400

@app.route("/forgot_password", methods = ["POST"])
def forgot_password():
    data = request.get_json()
    email = data['email']
    if (is_invalid_email(email)):
        otp = ""
        for _ in range(6):
            otp += str(random.randint(0, 9))

        cursor = mysql.connection.cursor()
        cursor.execute("SELECT*FROM users WHERE email = %s", (email,))
        user_info = cursor.fetchone()
        if (user_info is None):
            return jsonify({
                "message": "User not found"
            }),400
        else:
            cursor.execute("UPDATE users SET OTP_password = %s WHERE email = %s", (otp, email))
            mysql.connection.commit()
            cursor.close()

            server = SMTP("smtp.gmail.com", 587)
            server.starttls()

            from_mail = "appoaep@gmail.com"
            to_mail = email
            server.login(from_mail, "kvab rzkv toer idmn")

            msg = EmailMessage()
            msg["Subject"] = "Reset Password"
            msg["From"] = from_mail
            msg["To"] = to_mail
            msg.set_content(f"OTP Code {otp}")

            server.send_message(msg)

        return jsonify({
            "message": "Verification code sent successfully"
        }),200
    else:
        return jsonify({
            "message" : "Email format is incorrect"
        }),400


@app.route("/password_verify_OTP", methods = ["POST"])
def password_verify_OTP():
    data = request.get_json()
    otp = data['OTP']
    email = data["email"]
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM users WHERE email = %s", (email,))
    user_info = cursor.fetchone()
    if (user_info[6] == otp):
        return jsonify({
            "message" : "Your OTP has been successfully verified."
        }),200
    else:
        return jsonify({
            "message" : "OTP verification failed. Please try again."
        }),400


@app.route("/reset_password", methods = ["POST"])
def reset_password():
    data = request.get_json()
    email = data['email']
    password = data['password']
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE users SET password = %s WHERE email = %s", (password,email))
    mysql.connection.commit()
    cursor.close()
    if (is_invalid_password(password)):
        return jsonify({
            "message": "Your password has been successfully reset."
        }), 200
    else:
        return jsonify({
            "message": "Password must be at least one letter, one number and 8 characters."
        }), 400


@app.route('/forgot_password_resendOTP', methods = ["POST"])
def forgot_password_resendOTP():
    data = request.get_json()
    email = data["email"]

    otp = ""
    for _ in range(6):
        otp += str(random.randint(0, 9))

    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE users SET OTP_password = %s WHERE email = %s", (otp, email))
    mysql.connection.commit()
    cursor.close()

    server = SMTP("smtp.gmail.com", 587)
    server.starttls()

    from_mail = "appoaep@gmail.com"
    to_mail = email
    server.login(from_mail, "kvab rzkv toer idmn")

    msg = EmailMessage()
    msg["Subject"] = "Reset Password"
    msg["From"] = from_mail
    msg["To"] = to_mail
    msg.set_content(f"OTP Code {otp}")

    server.send_message(msg)

    return jsonify({
        "message": "Verification code sent successfully"
    })


@app.route("/push_profile_image", methods = ["POST"])
def upload_profile_image():
    data = request.args
    username = data.get('username')

    file = request.files
    profile_image = file['profile_image']

    if not os.path.exists("profile_image/" + username):
        os.makedirs("profile_image/" + username)
    filename = secure_filename(profile_image.filename)
    profile_image.save("profile_image/" + username + "/" + filename)

    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE users SET profile_image = %s WHERE username = %s", ("profile_image/" + username + "/" + filename, username))
    mysql.connection.commit()
    cursor.close()
    return jsonify({
        "message" : "Your profile picture has been successfully uploaded."
    })


@app.route("/get_profile_image", methods = ["GET"])
def get_profile_image():
    data = request.args
    email = data.get("email")

    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM users WHERE email = %s",(email,))
    user_info = cursor.fetchone()
    return send_file(user_info[4])


@app.route("/all_users", methods = ["GET"])
def all_users():
    users_list = []
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT*FROM users')
    users = cursor.fetchall()
    mysql.connection.commit()

    for user in users:
        users_list.append({
            "id" : user[0],
            "name" : user[1],
            "email" : user[2],
            "profile_image" : user[4],
            "status" : user[8],
            "bio" : user[9]
        })
    cursor.close()
    return jsonify(users_list)


@app.route("/account_info", methods = ["GET"])
def account_info():
    data = request.args
    email = data['email']
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM users WHERE email = %s", (email,))
    account_info = cursor.fetchone()
    return jsonify({
        "id" : account_info[0],
        "name" : account_info[1]
    })


@app.route("/push_group_members", methods = ["POST"])
def push_group_members():
    data = request.get_json()
    sender_id = data['sender_id']
    receiver_id = data['receiver_id']
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT*FROM group_members WHERE sender_id = %s AND receiver_id = %s',(sender_id,receiver_id))
    group_element = cursor.fetchone()
    empty_message_list = json.dumps([])
    if (sender_id != receiver_id):
        if (group_element is None):
            cursor.execute("INSERT INTO group_members (sender_id, receiver_id,messages,receiver_status) VALUES(%s,%s,%s,%s)", (sender_id,receiver_id,empty_message_list,"offline"))
            mysql.connection.commit()
            cursor.close()
            return jsonify({
                "message" : "Added to your friends list."
            }),200
        else:
            return jsonify({
                "message" : "The user is already in your friends list."
            }),400
    else:
        return jsonify({
            "message" : "You cannot send a friend request to yourself."
        }),400


@app.route("/all_friends", methods=["POST"])
def all_friends():
    data = request.get_json()
    sender_id = data['sender_id']
    friend_list = []
    friend_info_list = []
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM group_members WHERE sender_id = %s", (sender_id,))
    my_friends = cursor.fetchall()

    for friend in my_friends:
        friend_list.append(
            {
                "receiver_id": friend[2]
            }
        )

    for friend_info in friend_list:
        cursor.execute("SELECT * FROM users WHERE id = %s", (friend_info['receiver_id'],))
        friend_info_cursor = cursor.fetchone()

        cursor.execute("SELECT * FROM group_members WHERE sender_id = %s AND receiver_id = %s", (sender_id, friend_info_cursor[0]))
        friend_message_info = cursor.fetchone()

        if friend_message_info and friend_message_info[3]:
            messages = json.loads(friend_message_info[3])
            if messages:
                last_message_username = messages[-1]['sender_id']
                cursor.execute("SELECT * FROM users WHERE id = %s", (last_message_username,))
                last_mes_name = cursor.fetchone()
                last_message = messages[-1]
            else:
                last_message_username = ""
                last_mes_name = ["", ""]
                last_message = {}
        else:
            last_message_username = ""
            last_mes_name = ["", ""]
            last_message = {}

        friend_info_list.append({
            "id": friend_info_cursor[0],
            "name": friend_info_cursor[1],
            "email": friend_info_cursor[2],
            "profile_image": friend_info_cursor[4],
            "bio": friend_info_cursor[9],
            "status": friend_info_cursor[8],
            "token": friend_info_cursor[10],
            "message": last_message,
            "last_message_username": last_mes_name[1]
        })

    return jsonify(friend_info_list)



@app.route("/send_message", methods = ["POST"])
async def send_message():
    data = request.get_json()
    sender_id = data["sender_id"]
    receiver_id = data['receiver_id']
    message = data['message']
    created_at_message = data['created_at_message']
    message_type = data['message_type']
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM group_members WHERE sender_id = %s AND receiver_id = %s",(sender_id,receiver_id))
    group_member = cursor.fetchone()
    if (group_member[3] is not None):
        message_list = json.loads(group_member[3])
        message_list.append({
            "sender_id" : sender_id,
            "receiver_id" : receiver_id,
            "message" : message,
            "created_at_message" : created_at_message,
            "message_type" : message_type,
            "status" : "waiting"
        })
        update_message_list = json.dumps(message_list)
        cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s",(update_message_list,sender_id,receiver_id))
        cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s",(update_message_list,receiver_id,sender_id))
        mysql.connection.commit()
        cursor.close()
        return jsonify(message_list)


@app.route("/get_messages", methods = ["POST"])
def all_messages():
    data = request.get_json()
    sender_id = data['sender_id']
    receiver_id = data['receiver_id']
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT*FROM group_members WHERE sender_id = %s AND receiver_id = %s',(sender_id,receiver_id))
    message = cursor.fetchone()
    messages = json.loads(message[3])
    return jsonify(messages),200


@app.route('/send_message_file', methods = ["POST"])
def send_message_file():
    data = request.args
    sender_id = data.get("sender_id")
    receiver_id = data.get("receiver_id")
    created_at_message = data.get('created_at_message')
    message_type = data.get('message_type')
    #############################################
    file = request.files
    files = file['file']
    if not os.path.exists("chatImage/" + sender_id + "and" + receiver_id):
        os.makedirs("chatImage/" + sender_id + "and" + receiver_id)
    if not os.path.exists("chatImage/" + receiver_id + "and" + sender_id):
        os.makedirs("chatImage/" + receiver_id + "and" + sender_id)

    filename = secure_filename(files.filename)
    file_path = "chatImage/" + receiver_id + "and" + sender_id + '/' + filename

    files.save(file_path)

    shutil.copy(file_path, "chatImage/" + sender_id + "and" + receiver_id + '/' + filename)
    ##############################################
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM group_members WHERE sender_id = %s AND receiver_id = %s", (sender_id, receiver_id))
    group_member = cursor.fetchone()
    if group_member[3] is not None:
        message_list = json.loads(group_member[3])
        message_list.append({
            "sender_id": int(sender_id),
            "receiver_id": int(receiver_id),
            "message": filename,
            "created_at_message": created_at_message,
            "message_type": message_type,
            "status" : "waiting"
        })
        update_message_list = json.dumps(message_list)
        cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s", (update_message_list, sender_id, receiver_id))
        cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s", (update_message_list, receiver_id, sender_id))
        mysql.connection.commit()
        cursor.close()
        return jsonify(message_list)


@app.route("/get_file_message", methods = ["GET"])
def get_file_message():
    data = request.args
    sender_id = data.get("sender_id")
    receiver_id = data.get("receiver_id")
    filename = data.get("filename")
    file_path = f"chatImage/{sender_id}and{receiver_id}/{filename}"
    return send_file(file_path)


@app.route('/send_message_sound', methods = ["POST"])
def send_message_sound():
    data = request.args
    sender_id = data.get("sender_id")
    receiver_id = data.get("receiver_id")
    created_at_message = data.get('created_at_message')
    message_type = data.get('message_type')
    #############################################
    file = request.files
    files = file['sound']
    if not os.path.exists("chatSound/" + sender_id + "and" + receiver_id):
        os.makedirs("chatSound/" + sender_id + "and" + receiver_id)
    if not os.path.exists("chatSound/" + receiver_id + "and" + sender_id):
        os.makedirs("chatSound/" + receiver_id + "and" + sender_id)

    filename = secure_filename(files.filename)
    file_path = "chatSound/" + receiver_id + "and" + sender_id + '/' + filename

    files.save(file_path)

    shutil.copy(file_path, "chatSound/" + sender_id + "and" + receiver_id + '/' + filename)
    ##############################################
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM group_members WHERE sender_id = %s AND receiver_id = %s", (sender_id, receiver_id))
    group_member = cursor.fetchone()
    if group_member[3] is not None:
        message_list = json.loads(group_member[3])
        message_list.append({
            "sender_id": int(sender_id),
            "receiver_id": int(receiver_id),
            "message": filename,
            "created_at_message": created_at_message,
            "message_type": message_type,
            "status" : "waiting"
        })
        update_message_list = json.dumps(message_list)
        cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s", (update_message_list, sender_id, receiver_id))
        cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s", (update_message_list, receiver_id, sender_id))
        mysql.connection.commit()
        cursor.close()
        return jsonify(message_list),200


@app.route("/get_message_sound", methods = ["GET"])
def get_message_sound():
    data = request.args
    sender_id = data.get('sender_id')
    receiver_id = data.get("receiver_id")
    sound_path = data.get("sound_path")
    return send_file(f"chatSound/{sender_id}and{receiver_id}/{sound_path}")

@app.route("/set_status", methods = ["POST"])
def set_status():
    data = request.get_json()
    status = data['status']
    email = data['email']
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE users SET status = %s WHERE email = %s", (status, email))
    mysql.connection.commit()
    cursor.close()
    return jsonify({'message' : "status successfull changed"})


@app.route("/deleted_messages", methods = ["GET"])
def deleted_messages():
    data = request.args
    created_at_time = data.get("created_at")
    sender_id = data.get("sender_id")
    receiver_id = data.get("receiver_id")
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM group_members WHERE sender_id = %s AND receiver_id = %s", (sender_id, receiver_id))
    groups_members = cursor.fetchone()
    messages_list = json.loads(groups_members[3])
    for messages in messages_list:
        if (messages["created_at_message"] == created_at_time):
            messages_list.remove(messages)
            cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s",
                           (json.dumps(messages_list), sender_id, receiver_id))
            cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s",
                           (json.dumps(messages_list), receiver_id, sender_id))
            mysql.connection.commit()
            cursor.close()
            return jsonify(messages_list)


@app.route("/add_bio", methods = ["POST"])
def add_bio():
    data = request.get_json()
    email = data['email']
    bio = data['bio']
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE users SET bio = %s WHERE email = %s",(bio,email))
    mysql.connection.commit()
    cursor.close()
    return jsonify({
        "message" : "Your bio has been successfully added"
    }),200


@app.route("/set_receiver_status", methods = ["POST"])
def set_receiver_status():
    data = request.get_json()
    sender_id = data['sender_id']
    receiver_id = data['receiver_id']
    receiver_status = data['receiver_status']
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE group_members SET receiver_status = %s WHERE sender_id = %s AND receiver_id = %s",(receiver_status,receiver_id,sender_id))
    mysql.connection.commit()
    cursor.close()
    return jsonify("")


@app.route("/message_status", methods = ["POST"])
def message_status():
    data = request.get_json()
    sender_id = data['sender_id']
    receiver_id = data['receiver_id']
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT*FROM group_members WHERE sender_id = %s AND receiver_id = %s",(sender_id, receiver_id))
    group_info = cursor.fetchone()
    group_info_list = json.loads(group_info[3])
    for message in group_info_list:
        if message['sender_id'] == receiver_id:
            message['status'] = "seen"
    updated_group_info = json.dumps(group_info_list)
    cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s",
                   (updated_group_info, sender_id, receiver_id))
    cursor.execute("UPDATE group_members SET messages = %s WHERE sender_id = %s AND receiver_id = %s",
                   (updated_group_info, receiver_id, sender_id))
    mysql.connection.commit()
    return jsonify(group_info_list),200


@app.route("/send_notification", methods = ["POST"])
def send_notification():
    data = request.get_json()
    token = data['token']
    title = data['title']
    body = data['body']
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=token
    )

    messaging.send(message)

    return jsonify({
        "message" : "Notification sent successfully"
    }),200


@app.route("/update_token", methods = ["POST"])
def update_token():
    data = request.get_json()
    email = data['email']
    token = data['token']
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE users SET token = %s WHERE email = %s",(token,email))
    mysql.connection.commit()
    cursor.close()
    return jsonify({
        "message" : "Token update successfully"
    })


@app.route("/id_info", methods = ["POST"])
def id_info():
    data = request.get_json()
    id = data['id']
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT*FROM users WHERE id = %s', (id,))
    account_info = cursor.fetchone()
    mysql.connection.commit()
    cursor.close()
    return jsonify({
        "name" : account_info[1]
    })

if (__name__ == "__main__"):
    app.run(debug=True)
