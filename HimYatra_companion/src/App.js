import React, { useState, useEffect } from 'react';
import { Container, Typography, Box, CircularProgress, Tabs, Tab } from '@mui/material';
import BookingCard from './components/BookingCard';
import PricingManager from './components/PricingManager';
import OccupancyDashboard from './components/OccupancyDashboard';
import AppView from './components/AppView';
import { motion } from 'framer-motion';

const MotionBox = motion(Box);
const MotionTypography = motion(Typography);

function App() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentTab, setCurrentTab] = useState(0);

  useEffect(() => {
    const checkForFile = async () => {
      try {
        const response = await fetch('/data/hotels.json');
        if (response.ok) {
          const data = await response.json();
          setBookings(data.bookings.map(booking => ({
            ...booking,
            status: booking.status?.toLowerCase() || 'pending'
          })));
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

  const handleTabChange = (event, newValue) => {
    setCurrentTab(newValue);
  };

  return (
    <Box 
      sx={{ 
        minHeight: '100vh',
        background: 'linear-gradient(to bottom, #000000, #111111)',
        color: 'white',
        pb: 8,
        position: 'relative',
        overflow: 'hidden',
        '&::before': {
          content: '""',
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: '100%',
          background: 'radial-gradient(circle at 50% 0%, rgba(255, 255, 255, 0.07), transparent 70%)',
          pointerEvents: 'none',
          backdropFilter: 'blur(100px)',
        }
      }}
    >
      <Container maxWidth="xl">
        <MotionBox
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          sx={{
            pt: 12,
            pb: 6,
            textAlign: 'center',
            position: 'relative',
          }}
        >
          <MotionTypography
            variant="h2"
            component="h1"
            sx={{
              fontFamily: 'Lato',
              fontWeight: 700,
              fontSize: { xs: '2.5rem', md: '3.75rem' },
              letterSpacing: '-0.02em',
              color: '#ffffff',
              mb: 3,
              position: 'relative',
              display: 'inline-block',
              '&::after': {
                content: '""',
                position: 'absolute',
                bottom: -16,
                left: '50%',
                transform: 'translateX(-50%)',
                width: '40px',
                height: '1px',
                background: 'rgba(255, 255, 255, 0.3)',
              }
            }}
          >
            HimYatra Companion
          </MotionTypography>
          <MotionTypography
            variant="h6"
            sx={{
              fontFamily: 'Lato',
              color: 'rgba(255, 255, 255, 0.6)',
              fontWeight: 400,
              maxWidth: '600px',
              margin: '0 auto',
              lineHeight: 1.6,
              fontSize: '1.1rem',
              mt: 4,
              fontStyle: 'italic'
            }}
          >
            Manage your mountain getaway bookings with elegance
          </MotionTypography>
        </MotionBox>

        <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 4 }}>
          <Tabs 
            value={currentTab} 
            onChange={handleTabChange}
            centered
            sx={{
              '& .MuiTab-root': {
                color: 'rgba(255, 255, 255, 0.7)',
                '&.Mui-selected': {
                  color: 'white',
                },
              },
              '& .MuiTabs-indicator': {
                backgroundColor: 'white',
              },
            }}
          >
            <Tab label="Bookings" />
            <Tab label="Pricing Manager" />
            <Tab label="Occupancy Dashboard" />
            <Tab label="App View" />
          </Tabs>
        </Box>

        {currentTab === 0 ? (
          <>
            <MotionBox
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              <Typography
                variant="h4"
                component="h2"
                sx={{
                  mb: 8,
                  color: '#ffffff',
                  fontFamily: 'Lato',
                  fontWeight: 500,
                  fontSize: '2.25rem',
                  letterSpacing: '-0.02em',
                  position: 'relative',
                  display: 'inline-block',
                  '&::after': {
                    content: '""',
                    position: 'absolute',
                    bottom: -8,
                    left: 0,
                    width: '20px',
                    height: '1px',
                    background: 'rgba(255, 255, 255, 0.3)',
                  }
                }}
              >
                Available Bookings
              </Typography>
            </MotionBox>

            {loading ? (
              <MotionBox 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.4 }}
                display="flex" 
                justifyContent="center" 
                alignItems="center" 
                minHeight="300px"
              >
                <CircularProgress 
                  size={40}
                  sx={{ 
                    color: 'rgba(255, 255, 255, 0.3)',
                    '& .MuiCircularProgress-circle': {
                      strokeLinecap: 'round',
                    }
                  }} 
                />
              </MotionBox>
            ) : error ? (
              <MotionBox
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.4 }}
                sx={{
                  textAlign: 'center',
                  py: 10,
                  px: 4,
                  borderRadius: '20px',
                  background: 'rgba(255, 255, 255, 0.03)',
                  backdropFilter: 'blur(20px)',
                  border: '1px solid rgba(255, 255, 255, 0.05)',
                  maxWidth: '600px',
                  margin: '0 auto'
                }}
              >
                <Typography 
                  variant="h5" 
                  sx={{ 
                    color: 'rgba(255, 255, 255, 0.8)',
                    fontFamily: 'Lato',
                    fontWeight: 400,
                    fontSize: '1.25rem'
                  }}
                >
                  {error}
                </Typography>
              </MotionBox>
            ) : (
              <MotionBox
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.6 }}
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
                {bookings.map((booking, index) => (
                  <MotionBox
                    key={booking.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ 
                      duration: 0.6, 
                      delay: index * 0.1,
                      ease: [0.22, 1, 0.36, 1]
                    }}
                  >
                    <BookingCard
                      booking={booking}
                      onConfirm={() => handleConfirmBooking(booking.id)}
                    />
                  </MotionBox>
                ))}
              </MotionBox>
            )}
          </>
        ) : currentTab === 1 ? (
          <PricingManager />
        ) : currentTab === 2 ? (
          <OccupancyDashboard />
        ) : (
          <AppView />
        )}
      </Container>
    </Box>
  );
}

export default App; 