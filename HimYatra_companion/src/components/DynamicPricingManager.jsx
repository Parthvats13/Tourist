import React, { useState, useEffect } from 'react';
import { Box, Typography, TextField, Button, Paper, Alert } from '@mui/material';
import { motion } from 'framer-motion';
import axios from 'axios';

const DynamicPricingManager = () => {
  const [deluxePrice, setDeluxePrice] = useState('');
  const [premiumSuitePrice, setPremiumSuitePrice] = useState('');
  const [message, setMessage] = useState({ type: '', text: '' });

  useEffect(() => {
    // Fetch initial prices when component mounts
    fetchPrices();
  }, []);

  const fetchPrices = async () => {
    try {
      const response = await axios.get('http://localhost:3001/api/hotels');
      const hotel = response.data.hotels[0];
      const deluxeRoom = hotel.roomTypes.find(room => room.name === 'Deluxe');
      const premiumSuite = hotel.roomTypes.find(room => room.name === 'Premium Suite');
      
      setDeluxePrice(deluxeRoom.price.toString());
      setPremiumSuitePrice(premiumSuite.price.toString());
    } catch (error) {
      setMessage({ type: 'error', text: 'Error fetching prices' });
    }
  };

  const handleSave = async () => {
    try {
      await axios.put('http://localhost:3001/api/hotels/update-prices', {
        deluxePrice: parseInt(deluxePrice),
        premiumSuitePrice: parseInt(premiumSuitePrice)
      });
      setMessage({ type: 'success', text: 'Prices updated successfully!' });
    } catch (error) {
      setMessage({ type: 'error', text: 'Error updating prices' });
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <Paper elevation={3} sx={{ p: 3, mb: 3 }}>
        <Typography variant="h5" gutterBottom>
          Dynamic Pricing Manager
        </Typography>
        
        {message.text && (
          <Alert severity={message.type} sx={{ mb: 2 }}>
            {message.text}
          </Alert>
        )}

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField
            label="Deluxe Room Price (₹)"
            type="number"
            value={deluxePrice}
            onChange={(e) => setDeluxePrice(e.target.value)}
            fullWidth
          />
          
          <TextField
            label="Premium Suite Price (₹)"
            type="number"
            value={premiumSuitePrice}
            onChange={(e) => setPremiumSuitePrice(e.target.value)}
            fullWidth
          />

          <Button
            variant="contained"
            color="primary"
            onClick={handleSave}
            sx={{ mt: 2 }}
          >
            Save Prices
          </Button>
        </Box>
      </Paper>
    </motion.div>
  );
};

export default DynamicPricingManager; 