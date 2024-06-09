import argparse
import os

from CloudDatabase import CloudDatabase
from LocalDatabse import LocalDatabase
from flask import Flask, request

parser = argparse.ArgumentParser()
parser.add_argument("-r", "--storage", help="Storage Method")

app = Flask(__name__)


# TODO:
#   - Write a test for negative cells in the formula
#   - Pass test 11: GET a cell doesn't exist
#   - Write some DELETE tests

def run_paths(database):
    @app.route('/cells/<id>', methods=['GET', 'DELETE', 'PUT'])
    def cell_functions(id):
        """
        Function to respond to a request to /cells/<id>

        :param id: id of the cell
        :return: Http Status Code
        """

        # ------------- PUT METHOD ---------------- #
        # Can update the cell in here
        if request.method == 'PUT':
            # Was not able to access the data

            try:
                cell = request.json['id']
                formula = request.json['formula']
                if cell != id:
                    return "", 400
            except:
                return "", 400

            # Bad request
            if cell is None or formula is None:
                return "", 400

            if database.get_cell(cell) is None:
                # Creating a new cell
                u = database.insert_cell(cell, formula)

                if u is not None:
                    return "", 201
                else:
                    return "", 500
            else:
                # Cell exists so we edit it

                u = database.update_cell(cell, formula)
                if u is not None:
                    return "", 204
                else:
                    return "", 500

        # ------------- GET METHOD ---------------- #
        if request.method == 'GET':
            """
            GET /cells/<id>
            return { id: <cell_id>, formula: <formula>}

            Read and interpret what is in the cells here
            """
            if id is None:
                return "", 404

            if not database.get_formula(id):
                return "", 404

            u = database.get_cell(id)
            if u is not None:
                # Add parenthesis around the expression
                if u[1] == '' or u[1] == " ":
                    return {'id': u[0], 'formula': "0"}, 200

                try:
                    calculation = str(database.calculate(f'({u[1]})'))
                except:
                    return "", 500

                return {'id': u[0], 'formula': calculation}, 200
            else:
                return "", 500

        # ------------ DELETE METHOD ----------- #
        if request.method == 'DELETE':

            if id is None:
                return "", 404

            u = database.delete_cell(id)
            if u == 1:
                return "", 204
            elif u == 0:
                return "", 404
            else:
                return "", 500

    @app.route('/cells', methods=['GET'])
    def list_cells():
        """
        Listing Cells

        GET /cells
        """
        if request.method == 'GET':
            cells = database.list_cells()
            if cells is not None:
                return cells, 200
            else:
                return "", 500


if __name__ == "__main__":

    args = parser.parse_args()

    if args.storage == 'firebase':
        print("Using Cloud Storage")

        firebase = os.environ.get('FBASE')

        run_paths(CloudDatabase(firebase))
    elif args.storage == 'sqlite':
        print("Using Local Storage")
        run_paths(LocalDatabase())

    else:
        print("Unsupported storage type. Exiting Program...")
        exit()

    app.run(host='localhost', port=3000)
