import flask

from DatabaseHandler import DatabaseHandler
import os
import requests
import re


class CloudDatabase(DatabaseHandler):
    def __init__(self, firebase):
        self.reference_link = f'https://{firebase}-default-rtdb.europe-west1.firebasedatabase.app'
        print(self.reference_link)
        r = requests.delete(f'{self.reference_link}/cells.json')

    def insert_cell(self, cell_id, formula):
        r = requests.put(f'{self.reference_link}/cells/{cell_id}.json', json={"cell_id": cell_id, "formula": formula})
        if r.status_code == 200:
            return "Cell successfully inserted"
        return None

    def delete_cell(self, cell_id):

        if self.get_cell(cell_id) is None:
            return 0

        r = requests.delete(f'{self.reference_link}/cells/{cell_id}.json', json={"cell_id":  cell_id})

        if r.status_code == 200:
            return 1

        return None

    def update_cell(self, cell_id, formula):
        r = requests.patch(f'{self.reference_link}/cells/{cell_id}.json', json={"formula": formula})

        if r.status_code == 200:
            return "Cell updated successfully"
        return None

    def get_cell(self, cell_id):

        if self.get_formula(cell_id) is None:
            return None

        r = requests.get(f'{self.reference_link}/cells/{cell_id}.json')
        json_data = r.json()
        if json_data is not None:
            return json_data['cell_id'], json_data['formula']
        return None

    def get_formula(self, cell_id):
        r = requests.get(f'{self.reference_link}/cells/{cell_id}.json')
        json_data = r.json()
        if json_data is not None:
            return [json_data['formula']]
        return None

    def list_cells(self):
        r = requests.get(f'{self.reference_link}/cells.json')

        cells = []
        try:
            for [_, value] in r.json().items():
                cells.append(value['cell_id'])
        except AttributeError:
            pass
        return flask.jsonify(cells)
