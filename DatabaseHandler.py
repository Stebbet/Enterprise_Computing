import re


class DatabaseHandler:
    def insert_cell(self, cell_id, formula):
        pass

    def update_cell(self, cell_id, formula):
        pass

    def get_cell(self, cell_id):
        pass

    def delete_cell(self, cell_id):
        pass

    def get_formula(self, cell_id):
        pass

    def list_cells(self):
        pass

    def calculate(self, formula: str):
        tokens = re.findall(r'[A-Za-z]+\d+', formula)
        for token in tokens:
            fetched = self.get_formula(token)
            if fetched:
                new_token = fetched[0]
                if new_token == '':
                    new_token = '0'
                elif re.search(r'[A-Za-z]', new_token):
                    print(new_token)
                    new_token = self.calculate(new_token)

            else:
                return 0
            formula = formula.replace(token, f'( {new_token} )')

        return eval(formula)
