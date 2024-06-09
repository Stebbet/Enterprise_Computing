import sqlite3

import flask

from DatabaseHandler import DatabaseHandler
import os


class LocalDatabase(DatabaseHandler):

    def __init__(self):
        self.filename = 'identifier.sqlite'
        self.initialise_db()

    def connect_to_db(self):
        try:
            conn = sqlite3.connect(self.filename)
            return conn
        except sqlite3.Error as error:
            print("Connection Failed")
            raise error

    def initialise_db(self):
        try:

            with self.connect_to_db() as conn:
                cursor = conn.cursor()

                table = """ CREATE TABLE SPREADSHEET (
                                        CELL VARCHAR(255) NOT NULL PRIMARY KEY,
                                        FORMULA VARCHAR(25) NOT NULL
                                    );"""
                cursor.execute(table)
                print("Table is Ready")

                cursor.close()
        except sqlite3.OperationalError:
            print("Database already exists")

    def insert_cell(self, cell_id, formula):
        # Connecting to database
        with self.connect_to_db() as conn:
            cursor = conn.cursor()

            cmd = "INSERT INTO SPREADSHEET VALUES (\'" + cell_id + "\', \'" + formula + "\');"
            

            try:
                cursor.execute(cmd)
                conn.commit()
                cursor.close()
                return "SUCCESS"
            except sqlite3.Error:
                cursor.close()
                return None

    def delete_cell(self, cell_id):
        # Connecting to database

        if self.get_cell(cell_id) is None:
            return 0

        with self.connect_to_db() as conn:
            cursor = conn.cursor()

            cmd = "DELETE FROM SPREADSHEET WHERE CELL=\'" + cell_id + "\';"
            
            try:
                cursor.execute(cmd)
                conn.commit()
                cursor.close()
                return 1
            except sqlite3.Error:
                cursor.close()
                return None

    def update_cell(self, cell_id, formula):
        # Connecting to database
        with self.connect_to_db() as conn:
            cursor = conn.cursor()

            cmd = 'UPDATE SPREADSHEET SET FORMULA="{formula}" WHERE CELL="{cell_id}"'.format(cell_id=cell_id,
                                                                                             formula=formula)
            try:
                cursor.execute(cmd)
                conn.commit()
                cursor.close()
                return "SUCCESS"
            except sqlite3.Error:
                return None

    def get_cell(self, cell_id):
        # Connecting to database
        with self.connect_to_db() as conn:
            cursor = conn.cursor()

            cmd = "SELECT * FROM SPREADSHEET WHERE CELL=\'" + cell_id + "\';"
            try:
                cursor.execute(cmd)
                output = cursor.fetchone()
                print(output)
                cursor.close()
                return output
            except sqlite3.Error:
                return None

    def get_formula(self, cell_id):
        with self.connect_to_db() as conn:
            cursor = conn.cursor()
            cmd = "SELECT formula FROM SPREADSHEET WHERE CELL=\'" + cell_id + "\';"
            cursor.execute(cmd)
            return cursor.fetchone()

    def list_cells(self):
        # Connecting to database
        with self.connect_to_db() as conn:
            cursor = conn.cursor()

            try:
                cmd = "SELECT * FROM SPREADSHEET"
                cursor.execute(cmd)
                output = cursor.fetchall()
                cursor.close()
                return flask.jsonify([i[0] for i in output])
            except sqlite3.Error:
                return None
