"""
Unit tests for the Flask application
"""
import unittest
import json
import sys
import os

# Add src directory to path so we can import the app
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        """Set up test client"""
        self.app = app.test_client()
        self.app.testing = True
    
    def test_home_endpoint(self):
        """Test home endpoint returns correct data"""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertIn('message', data)
        self.assertIn('version', data)
        self.assertIn('status', data)
        self.assertEqual(data['status'], 'running')
    
    def test_health_check(self):
        """Test health check endpoint"""
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'healthy')
    
    def test_calculate_add(self):
        """Test addition calculation"""
        response = self.app.get('/calculate/add?a=5&b=3')
        self.assertEqual(response.status_code, 200)
        
        data = json.loads(response.data)
        self.assertEqual(data['result'], 8)
        self.assertEqual(data['operation'], 'add')
    
    def test_calculate_divide_by_zero(self):
        """Test division by zero returns error"""
        response = self.app.get('/calculate/divide?a=10&b=0')
        self.assertEqual(response.status_code, 400)
        
        data = json.loads(response.data)
        self.assertIn('error', data)
    
    def test_invalid_operation(self):
        """Test invalid operation returns error"""
        response = self.app.get('/calculate/invalid?a=1&b=2')
        self.assertEqual(response.status_code, 400)

if __name__ == '__main__':
    unittest.main()
