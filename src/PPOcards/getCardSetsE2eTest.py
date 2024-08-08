import unittest
import requests
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from uuid import uuid4

class TestCardSetsAPI(unittest.TestCase):
    def setUp(self):
        # Connect to the PostgreSQL database
        self.conn = psycopg2.connect(
            host="127.0.0.1",
            port=5432,
            dbname="webdb",
            user="web_admin",
            password="web_admin"
        )
        self.conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        self.cur = self.conn.cursor()

        # Clear the cardsets table
        self.cur.execute("DELETE FROM cardsets;")
        self.cur.execute("DELETE FROM cards;")

        # Insert test data into the cardsets table
        self.cur.execute("""
            INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
            VALUES (%s, %s, %s, %s, %s);
        """, (str(uuid4()), "Test Title 1", 10, 5, 123456))
        self.cur.execute("""
            INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
            VALUES (%s, %s, %s, %s, %s);
        """, (str(uuid4()), "Test Title 2", 15, 0, 0xFF0000))
        self.cur.execute("""
            INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
            VALUES (%s, %s, %s, %s, %s);
        """, (str(uuid4()), "Test Title 3", 0, 0, 0xFF00FF))

    def test_get_card_sets(self):
        # Send a GET request to the card_sets endpoint
        response = requests.get("http://localhost:8078/card_sets?limit=20&offset=0")

        # Check that the status code is 200
        self.assertEqual(response.status_code, 200)

        data = response.json()
        for item in data:
            if 'card_set_id' in item:
                del item['card_set_id']

        # Check that the response is as expected
        expected_data = [{
            "title": "Test Title 1",
            "all_cards_count": 10,
            "learned_cards_count": 5,
            "color": 123456
        },
        {
            "title": "Test Title 2",
            "all_cards_count": 15,
            "learned_cards_count": 0,
            "color": 0xFF0000
        },
        {
            "title": "Test Title 3",
            "all_cards_count": 0,
            "learned_cards_count": 0,
            "color": 0xFF00FF
        }]

        self.assertEqual(data, expected_data)

    def tearDown(self):
        # Close the database connection
        self.cur.close()
        self.conn.close()

if __name__ == "__main__":
    unittest.main()
