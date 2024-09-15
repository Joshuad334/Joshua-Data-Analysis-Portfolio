import pypyodbc as odbc  # pip install pypyodbc
import pandas as pd  # pip install pandas

# Step 1. Reads the file to check contents.
df = pd.read_csv('C:\\Users\\USER\\OneDrive\\Desktop\\TestCSV\\Customer.csv')

# Step 2. Data Clean up - This portion just cleans up the duplicates within the data.
print(df.duplicated())
df.drop_duplicates(inplace=True)

# Step 3. Specify columns we want to import - Columns have to be specified for import
columns = ['C_ID', 'M_ID', 'C_NAME', 'C_EMAIL_ID', 'C_TYPE', 'C_ADDR', 'C_CONT_NO']
df_data = df[columns]
records = df_data.values.tolist()

# Step 4. SQL Ingestion - Ingests the Data into SQL Server
Driver = "ODBC Driver 17 for SQL Server"
Server_Name = "DESKTOP-4COA7Q3\\SQLEXPRESS" # Fake Server Name for obvious reasons
Database_Name = "LogIstics" # Fake Database Name for obvious reasons

def connection_string(Driver, Server_Name, Database_Name):
    return f"""
        DRIVER={{{Driver}}};
        SERVER={Server_Name};
        DATABASE={Database_Name};
        Trusted_Connection=yes;
    """

try:
    conn = odbc.connect(connection_string(Driver, Server_Name, Database_Name))
except odbc.DatabaseError as e:
    print('Database Error:')
    print(str(e.args[1]))
except odbc.Error as e:
    print('Connection Error:')
    print(str(e.args[1]))

try:
    cursor = conn.cursor()
    insert_query = """
    INSERT INTO [Logistics].[dbo].[Customer] (C_ID, M_ID, C_NAME, C_EMAIL_ID, C_TYPE, C_ADDR, C_CONT_NO)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """
    for record in records:
        cursor.execute(insert_query, record)
    conn.commit()
except Exception as e:
    conn.rollback()
    print(str(e))
finally:
    print('Done')
    cursor.close()
    conn.close()
