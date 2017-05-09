from sites.tasks import add
from django.test import TestCase


class SimpleTestCase(TestCase):
    def test_add(self):
        """dummy test"""
        self.assertEqual(add(1, 4), 5)
