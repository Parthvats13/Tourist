import React, { useState, useEffect } from 'react';
import { Container, Typography, Box, CircularProgress } from '@mui/material';
import BookingCard from './components/BookingCard';

function App() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const checkForFile = async () => {
      try {
        const response = await fetch('/data/hotels.json');
        if (response.ok) {
          const data = await response.json();
          setBookings(data);
          setError(null);
        } else {
          setError('No users contacted');
        }
      } catch (err) {
        setError('No users contacted');
      } finally {
        setLoading(false);
      }
    };

    // Check for file every 5 seconds
    const interval = setInterval(checkForFile, 5000);
    checkForFile(); // Initial check

    return () => clearInterval(interval);
  }, []);

  const handleConfirmBooking = (bookingId) => {
    // Handle booking confirmation
    setBookings(prevBookings =>
      prevBookings.map(booking =>
        booking.id === bookingId
          ? { ...booking, status: 'confirmed' }
          : booking
      )
    );
  };

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#121212', color: 'white' }}>
      <Container maxWidth="xl">
        <Typography
          variant="h3"
          component="h1"
          sx={{
            py: 4,
            fontWeight: 'bold',
            color: 'white'
          }}
        >
          HimYatra Companion
        </Typography>

        <Typography
          variant="h5"
          component="h2"
          sx={{
            mb: 4,
            color: 'rgba(255, 255, 255, 0.87)'
          }}
        >
          Available Bookings
        </Typography>

        {loading ? (
          <Box display="flex" justifyContent="center" my={4}>
            <CircularProgress />
          </Box>
        ) : error ? (
          <Typography color="error" variant="h6">
            {error}
          </Typography>
        ) : (
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(350px, 1fr))',
              gap: 3,
              mb: 4
            }}
          >
            {bookings.map((booking) => (
              <BookingCard
                key={booking.id}
                booking={booking}
                onConfirm={() => handleConfirmBooking(booking.id)}
              />
            ))}
          </Box>
        )}
      </Container>
    </Box>
  );
}

export default App; 