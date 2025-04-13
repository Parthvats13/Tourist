const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

const HOTEL_DATA_PATH = path.join(__dirname, 'data', 'hotel_data.json');

// Helper function to read and validate hotel data
const readHotelData = () => {
    try {
        if (!fs.existsSync(HOTEL_DATA_PATH)) {
            throw new Error(`Hotel data file not found at: ${HOTEL_DATA_PATH}`);
        }

        const fileContent = fs.readFileSync(HOTEL_DATA_PATH, 'utf8');
        const data = JSON.parse(fileContent);

        if (!Array.isArray(data)) {
            throw new Error('Invalid hotel data format: expected an array of hotels');
        }

        return data;
    } catch (error) {
        console.error('Error reading hotel data:', error);
        throw error;
    }
};

// Read hotel data
app.get('/api/hotels', (req, res) => {
    try {
        const data = readHotelData();
        res.json({ hotels: data });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update hotel prices
app.put('/api/hotels/update-prices', (req, res) => {
    try {
        const { deluxePrice, premiumSuitePrice } = req.body;
        
        if (!deluxePrice || !premiumSuitePrice) {
            return res.status(400).json({ error: 'Missing required price values' });
        }

        console.log('Updating prices:', { deluxePrice, premiumSuitePrice });
        console.log('File path:', HOTEL_DATA_PATH);

        const hotels = readHotelData();

        // Update prices for all hotels
        hotels.forEach(hotel => {
            if (!hotel.roomTypes || !Array.isArray(hotel.roomTypes)) {
                throw new Error(`Invalid room types format for hotel ${hotel.id}`);
            }

            hotel.roomTypes.forEach(room => {
                if (room.name === 'Deluxe') {
                    room.price = parseInt(deluxePrice);
                } else if (room.name === 'Premium Suite') {
                    room.price = parseInt(premiumSuitePrice);
                }
            });
        });

        // Write the updated data back to the file
        console.log('Writing updated data to file...');
        fs.writeFileSync(HOTEL_DATA_PATH, JSON.stringify(hotels, null, 2));
        console.log('File updated successfully');
        
        res.json({ 
            message: 'Prices updated successfully',
            updatedPrices: {
                deluxe: deluxePrice,
                premiumSuite: premiumSuitePrice
            }
        });
    } catch (error) {
        console.error('Error updating prices:', error);
        res.status(500).json({ 
            error: 'Error updating prices',
            details: error.message 
        });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
}); 