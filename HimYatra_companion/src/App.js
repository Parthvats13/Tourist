import React, { useState, useEffect } from 'react';
import { Container, Typography, Box, CircularProgress, useTheme } from '@mui/material';
import BookingCard from './components/BookingCard';

function App() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const theme = useTheme();

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

    const interval = setInterval(checkForFile, 5000);
    checkForFile();

    return () => clearInterval(interval);
  }, []);

  const handleConfirmBooking = (bookingId) => {
    setBookings(prevBookings =>
      prevBookings.map(booking =>
        booking.id === bookingId
          ? { ...booking, status: 'confirmed' }
          : booking
      )
    );
  };

  return (
    <Box 
      sx={{ 
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #13151a 0%, #1f2937 100%)',
        color: 'white',
        pb: 8
      }}
    >
      <Container maxWidth="xl">
        <Box
          sx={{
            pt: 6,
            pb: 8,
            textAlign: 'center',
            position: 'relative',
            '&::after': {
              content: '""',
              position: 'absolute',
              bottom: 0,
              left: '50%',
              transform: 'translateX(-50%)',
              width: '100px',
              height: '4px',
              background: 'linear-gradient(90deg, #60a5fa 0%, #3b82f6 100%)',
              borderRadius: '2px'
            }
          }}
        >
          <Typography
            variant="h2"
            component="h1"
            sx={{
              fontWeight: 700,
              background: 'linear-gradient(90deg, #fff 0%, #94a3b8 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              mb: 2
            }}
          >
            HimYatra Companion
          </Typography>
          <Typography
            variant="h6"
            sx={{
              color: '#94a3b8',
              fontWeight: 400
            }}
          >
            Manage your mountain getaway bookings
          </Typography>
        </Box>

        <Typography
          variant="h4"
          component="h2"
          sx={{
            mb: 4,
            color: '#e2e8f0',
            fontWeight: 600,
            position: 'relative',
            display: 'inline-block',
            '&::after': {
              content: '""',
              position: 'absolute',
              bottom: -1,
              left: 0,
              width: '40%',
              height: '3px',
              background: '#3b82f6',
              borderRadius: '2px'
            }
          }}
        >
          Available Bookings
        </Typography>

        {loading ? (
          <Box 
            display="flex" 
            justifyContent="center" 
            alignItems="center" 
            minHeight="200px"
          >
            <CircularProgress sx={{ color: '#3b82f6' }} />
          </Box>
        ) : error ? (
          <Box
            sx={{
              textAlign: 'center',
              py: 8,
              px: 3,
              borderRadius: 4,
              backgroundColor: 'rgba(239, 68, 68, 0.1)',
              border: '1px solid rgba(239, 68, 68, 0.2)'
            }}
          >
            <Typography 
              variant="h5" 
              sx={{ 
                color: '#ef4444',
                fontWeight: 500
              }}
            >
              {error}
            </Typography>
          </Box>
        ) : (
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: {
                xs: '1fr',
                sm: 'repeat(2, 1fr)',
                lg: 'repeat(3, 1fr)',
                xl: 'repeat(4, 1fr)'
              },
              gap: 4,
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