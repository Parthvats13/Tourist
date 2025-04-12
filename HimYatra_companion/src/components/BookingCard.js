import React, { useState } from 'react';
import {
  Box,
  Typography,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Paper,
  Chip,
  IconButton,
} from '@mui/material';
import { styled } from '@mui/material/styles';

const StyledPaper = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(3),
  borderRadius: 16,
  background: 'linear-gradient(145deg, #1a1f2b 0%, #161923 100%)',
  color: 'white',
  position: 'relative',
  transition: 'all 0.3s ease-in-out',
  border: '1px solid rgba(255, 255, 255, 0.05)',
  '&:hover': {
    transform: 'translateY(-4px)',
    boxShadow: '0 12px 24px -10px rgba(0, 0, 0, 0.5)',
  }
}));

const StatusChip = styled(Chip)(({ status }) => ({
  borderRadius: '8px',
  fontWeight: 500,
  ...(status === 'confirmed' ? {
    background: 'linear-gradient(135deg, #059669 0%, #10b981 100%)',
    color: 'white',
  } : {
    background: 'linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%)',
    color: '#1a1f2b',
  })
}));

const InfoLabel = styled(Typography)({
  color: '#94a3b8',
  fontSize: '0.875rem',
  fontWeight: 500,
  marginBottom: '4px'
});

const InfoValue = styled(Typography)({
  color: '#e2e8f0',
  fontSize: '1rem',
  fontWeight: 500
});

const BookingCard = ({ booking, onConfirm }) => {
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);

  const handleConfirmClick = () => {
    setConfirmDialogOpen(true);
  };

  const handleConfirmBooking = () => {
    onConfirm();
    setConfirmDialogOpen(false);
  };

  return (
    <>
      <StyledPaper elevation={0}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 3 }}>
          <Box>
            <Typography variant="h5" sx={{ fontWeight: 700, mb: 1 }}>
              {booking.username}
            </Typography>
            <Typography sx={{ color: '#60a5fa', fontWeight: 500 }}>
              {booking.contact}
            </Typography>
          </Box>
          <StatusChip
            label={booking.status || 'Pending'}
            status={booking.status}
          />
        </Box>

        {booking.block && (
          <Chip
            label={booking.block}
            size="small"
            sx={{
              bgcolor: 'rgba(96, 165, 250, 0.1)',
              color: '#60a5fa',
              border: '1px solid rgba(96, 165, 250, 0.2)',
              borderRadius: '6px',
              mb: 3
            }}
          />
        )}

        <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 3, mb: 3 }}>
          <Box>
            <InfoLabel>Check-in</InfoLabel>
            <InfoValue>{booking.checkIn}</InfoValue>
          </Box>
          <Box>
            <InfoLabel>Check-out</InfoLabel>
            <InfoValue>{booking.checkOut}</InfoValue>
          </Box>
        </Box>

        <Typography 
          variant="h5" 
          sx={{ 
            color: '#10b981',
            fontWeight: 700,
            mb: 3,
            display: 'flex',
            alignItems: 'center',
            gap: 1
          }}
        >
          ₹{booking.price.toLocaleString()}
        </Typography>

        <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 3, mb: 3 }}>
          <Box>
            <InfoLabel>Gender</InfoLabel>
            <InfoValue>{booking.gender}</InfoValue>
          </Box>
          <Box>
            <InfoLabel>Nationality</InfoLabel>
            <InfoValue>{booking.nationality}</InfoValue>
          </Box>
        </Box>

        <Box sx={{ mb: 3 }}>
          <InfoLabel>Domicile</InfoLabel>
          <InfoValue>{booking.domicile}</InfoValue>
        </Box>

        <Button
          variant="contained"
          fullWidth
          onClick={handleConfirmClick}
          disabled={booking.status === 'confirmed'}
          sx={{
            background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
            color: 'white',
            py: 1.5,
            borderRadius: '10px',
            textTransform: 'none',
            fontSize: '1rem',
            fontWeight: 600,
            '&:hover': {
              background: 'linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%)',
            },
            '&:disabled': {
              background: '#1f2937',
              color: '#4b5563'
            }
          }}
        >
          Confirm Booking
        </Button>
      </StyledPaper>

      <Dialog
        open={confirmDialogOpen}
        onClose={() => setConfirmDialogOpen(false)}
        PaperProps={{
          sx: {
            bgcolor: '#1a1f2b',
            color: 'white',
            borderRadius: '16px',
            maxWidth: '400px'
          }
        }}
      >
        <DialogTitle sx={{ borderBottom: '1px solid rgba(255, 255, 255, 0.05)' }}>
          Confirm Booking
        </DialogTitle>
        <DialogContent sx={{ my: 2 }}>
          <Typography sx={{ color: '#e2e8f0' }}>
            Are you sure you want to confirm the booking for {booking.username}?
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button
            onClick={() => setConfirmDialogOpen(false)}
            sx={{
              color: '#94a3b8',
              '&:hover': {
                color: '#e2e8f0',
                background: 'rgba(255, 255, 255, 0.05)'
              }
            }}
          >
            Cancel
          </Button>
          <Button
            onClick={handleConfirmBooking}
            variant="contained"
            sx={{
              background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
              color: 'white',
              '&:hover': {
                background: 'linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%)',
              }
            }}
          >
            Confirm
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

export default BookingCard; 