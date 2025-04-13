import React from 'react';
import {
  Box,
  Typography,
  Paper,
  Chip,
} from '@mui/material';
import { styled } from '@mui/material/styles';
import { motion } from 'framer-motion';

const StyledPaper = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(4),
  borderRadius: 24,
  background: 'rgba(255, 255, 255, 0.03)',
  backdropFilter: 'blur(20px)',
  WebkitBackdropFilter: 'blur(20px)',
  color: 'white',
  position: 'relative',
  transition: 'all 0.4s cubic-bezier(0.22, 1, 0.36, 1)',
  border: '1px solid rgba(255, 255, 255, 0.05)',
  overflow: 'hidden',
  '&:hover': {
    transform: 'translateY(-8px)',
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    '&::before': {
      opacity: 1,
    }
  },
  '&::before': {
    content: '""',
    position: 'absolute',
    inset: 0,
    background: 'radial-gradient(circle at top right, rgba(255, 255, 255, 0.12), transparent 70%)',
    opacity: 0,
    transition: 'opacity 0.4s ease',
  }
}));

const StatusChip = styled(Chip)(({ status }) => ({
  borderRadius: '20px',
  padding: '0 12px',
  height: '28px',
  fontFamily: 'Lato',
  fontWeight: 500,
  fontSize: '0.85rem',
  background: 'rgba(23, 23, 23, 0.95)',
  backdropFilter: 'blur(10px)',
  WebkitBackdropFilter: 'blur(10px)',
  border: '1px solid rgba(255, 255, 255, 0.1)',
  color: status === 'alloted' ? 'rgb(52, 211, 153)' : 'rgb(250, 204, 21)',
  '& .MuiChip-label': {
    padding: '0'
  }
}));

const InfoLabel = styled(Typography)({
  color: 'rgba(255, 255, 255, 0.5)',
  fontSize: '0.875rem',
  fontFamily: 'Lato',
  fontWeight: 400,
  marginBottom: '4px',
  letterSpacing: '0.01em'
});

const InfoValue = styled(Typography)({
  color: 'rgba(255, 255, 255, 0.9)',
  fontSize: '1rem',
  fontFamily: 'Lato',
  fontWeight: 400,
  letterSpacing: '0.01em'
});

const InfoContainer = styled(Box)({
  padding: '16px',
  background: 'rgba(23, 23, 23, 0.95)',
  borderRadius: '16px',
  border: '1px solid rgba(255, 255, 255, 0.05)',
  transition: 'all 0.3s ease',
  '&:hover': {
    background: 'rgba(255, 255, 255, 0.05)',
  }
});

const MotionBox = motion(Box);

const BookingCard = ({ booking }) => {
  return (
    <StyledPaper elevation={0}>
      <MotionBox
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
      >
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 4 }}>
          <Box>
            <Typography 
              variant="h5" 
              sx={{ 
                fontFamily: 'Lato',
                fontWeight: 400,
                fontSize: '1.5rem',
                letterSpacing: '-0.02em',
                color: 'rgba(255, 255, 255, 0.95)',
                mb: 1,
              }}
            >
              {booking.username}
            </Typography>
            <Typography 
              sx={{ 
                fontFamily: 'Lato',
                color: 'rgba(255, 255, 255, 0.6)',
                fontWeight: 400,
                letterSpacing: '0.02em',
                fontSize: '0.9rem',
              }}
            >
              {booking.contact}
            </Typography>
          </Box>
          <StatusChip
            label={booking.roomAlloted === 'yes' ? 'Alloted' : 'Not Alloted'}
            status={booking.roomAlloted === 'yes' ? 'alloted' : 'not_alloted'}
          />
        </Box>

        {booking.block && (
          <Chip
            label={booking.block}
            size="small"
            sx={{
              fontFamily: 'Lato',
              background: 'rgba(255, 255, 255, 0.05)',
              color: 'rgba(255, 255, 255, 0.7)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              borderRadius: '12px',
              mb: 4,
              fontSize: '0.8rem',
              fontWeight: 400,
              '&:hover': {
                background: 'rgba(255, 255, 255, 0.08)',
              }
            }}
          />
        )}

        <InfoContainer sx={{ mb: 3 }}>
          <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 3 }}>
            <Box>
              <InfoLabel>Check-in</InfoLabel>
              <InfoValue>{booking.checkIn}</InfoValue>
            </Box>
            <Box>
              <InfoLabel>Check-out</InfoLabel>
              <InfoValue>{booking.checkOut}</InfoValue>
            </Box>
          </Box>
        </InfoContainer>

        <Typography 
          variant="h5" 
          sx={{ 
            fontFamily: 'Lato',
            color: 'rgba(255, 255, 255, 0.95)',
            fontWeight: 300,
            fontSize: '2rem',
            mb: 3,
            letterSpacing: '-0.02em'
          }}
        >
          ₹{booking.price.toLocaleString()}
        </Typography>

        <InfoContainer sx={{ mb: 3 }}>
          <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 3 }}>
            <Box>
              <InfoLabel>Gender</InfoLabel>
              <InfoValue>{booking.gender}</InfoValue>
            </Box>
            <Box>
              <InfoLabel>Nationality</InfoLabel>
              <InfoValue>{booking.nationality}</InfoValue>
            </Box>
          </Box>
        </InfoContainer>

        <InfoContainer sx={{ mb: 4 }}>
          <InfoLabel>Domicile</InfoLabel>
          <InfoValue>{booking.domicile}</InfoValue>
        </InfoContainer>
      </MotionBox>
    </StyledPaper>
  );
};

export default BookingCard; 