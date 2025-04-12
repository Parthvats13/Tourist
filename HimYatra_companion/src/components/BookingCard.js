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
  Chip
} from '@mui/material';

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
      <Paper
        elevation={3}
        sx={{
          p: 3,
          borderRadius: 2,
          bgcolor: '#1E1E1E',
          color: 'white',
          position: 'relative',
          '&:hover': {
            transform: 'translateY(-2px)',
            transition: 'transform 0.2s'
          }
        }}
      >
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
          <Typography variant="h5" component="h3" sx={{ fontWeight: 'bold' }}>
            {booking.username}
          </Typography>
          <Chip
            label={booking.status || 'Pending'}
            sx={{
              bgcolor: booking.status === 'confirmed' ? '#4CAF50' : '#FFC107',
              color: 'black'
            }}
          />
        </Box>

        <Typography variant="body1" sx={{ color: 'rgba(255, 255, 255, 0.7)', mb: 1 }}>
          {booking.contact}
        </Typography>

        {booking.block && (
          <Chip
            label={booking.block}
            size="small"
            sx={{ bgcolor: '#333', color: 'white', mb: 2 }}
          />
        )}

        <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2, mb: 3 }}>
          <Box>
            <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.6)' }}>
              Check-in
            </Typography>
            <Typography variant="body1">{booking.checkIn}</Typography>
          </Box>
          <Box>
            <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.6)' }}>
              Check-out
            </Typography>
            <Typography variant="body1">{booking.checkOut}</Typography>
          </Box>
        </Box>

        <Typography variant="h6" sx={{ color: '#4CAF50', mb: 3 }}>
          ₹{booking.price.toLocaleString()}
        </Typography>

        <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2, mb: 3 }}>
          <Box>
            <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.6)' }}>
              Gender
            </Typography>
            <Typography variant="body1">{booking.gender}</Typography>
          </Box>
          <Box>
            <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.6)' }}>
              Nationality
            </Typography>
            <Typography variant="body1">{booking.nationality}</Typography>
          </Box>
        </Box>

        <Box>
          <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.6)' }}>
            Domicile
          </Typography>
          <Typography variant="body1">{booking.domicile}</Typography>
        </Box>

        <Button
          variant="contained"
          fullWidth
          sx={{
            mt: 3,
            bgcolor: 'white',
            color: 'black',
            '&:hover': {
              bgcolor: 'rgba(255, 255, 255, 0.9)'
            }
          }}
          onClick={handleConfirmClick}
          disabled={booking.status === 'confirmed'}
        >
          Confirm Booking
        </Button>
      </Paper>

      <Dialog
        open={confirmDialogOpen}
        onClose={() => setConfirmDialogOpen(false)}
        PaperProps={{
          sx: {
            bgcolor: '#1E1E1E',
            color: 'white'
          }
        }}
      >
        <DialogTitle>Confirm Booking</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to confirm the booking for {booking.username}?
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button
            onClick={() => setConfirmDialogOpen(false)}
            sx={{ color: 'rgba(255, 255, 255, 0.7)' }}
          >
            Cancel
          </Button>
          <Button
            onClick={handleConfirmBooking}
            variant="contained"
            sx={{
              bgcolor: 'white',
              color: 'black',
              '&:hover': {
                bgcolor: 'rgba(255, 255, 255, 0.9)'
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