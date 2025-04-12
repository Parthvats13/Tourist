import { styled } from '@mui/material/styles';
import { Box, Paper, Card, Typography, Button, Chip, Dialog } from '@mui/material';
import { motion } from 'framer-motion';

// Motion components
export const MotionBox = motion(Box);
export const MotionPaper = motion(Paper);
export const MotionCard = motion(Card);
export const MotionTypography = motion(Typography);
export const MotionChip = motion(Chip);

// Styled components
export const GlassCard = styled(Card)(({ theme }) => ({
  background: 'rgba(255, 255, 255, 0.03)',
  backdropFilter: 'blur(20px)',
  WebkitBackdropFilter: 'blur(20px)',
  border: '1px solid rgba(255, 255, 255, 0.05)',
  borderRadius: '16px',
  transition: 'all 0.3s ease',
  '&:hover': {
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.2)',
  }
}));

export const GlassPaper = styled(Paper)(({ theme }) => ({
  background: 'rgba(255, 255, 255, 0.03)',
  backdropFilter: 'blur(20px)',
  WebkitBackdropFilter: 'blur(20px)',
  border: '1px solid rgba(255, 255, 255, 0.05)',
  borderRadius: '16px',
  transition: 'all 0.3s ease',
  '&:hover': {
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
  }
}));

export const GlassButton = styled(Button)(({ theme }) => ({
  background: 'rgba(255, 255, 255, 0.05)',
  backdropFilter: 'blur(10px)',
  color: 'white',
  border: '1px solid rgba(255, 255, 255, 0.1)',
  borderRadius: '8px',
  transition: 'all 0.3s ease',
  '&:hover': {
    background: 'rgba(255, 255, 255, 0.1)',
    border: '1px solid rgba(255, 255, 255, 0.2)',
  }
}));

export const GlassChip = styled(Chip)(({ theme, status }) => ({
  borderRadius: '20px',
  padding: '0 12px',
  height: '28px',
  fontFamily: 'Lato',
  fontWeight: 500,
  fontSize: '0.85rem',
  background: status === 'occupied' 
    ? 'rgba(239, 68, 68, 0.15)' 
    : status === 'vacant' 
      ? 'rgba(34, 197, 94, 0.15)' 
      : status === 'maintenance' 
        ? 'rgba(234, 179, 8, 0.15)' 
        : status === 'cleaning'
          ? 'rgba(59, 130, 246, 0.15)'
          : 'rgba(255, 255, 255, 0.05)',
  color: status === 'occupied' 
    ? 'rgb(239, 68, 68)' 
    : status === 'vacant' 
      ? 'rgb(34, 197, 94)' 
      : status === 'maintenance' 
        ? 'rgb(234, 179, 8)' 
        : status === 'cleaning'
          ? 'rgb(59, 130, 246)'
          : 'white',
  border: `1px solid ${
    status === 'occupied' 
      ? 'rgba(239, 68, 68, 0.3)' 
      : status === 'vacant' 
        ? 'rgba(34, 197, 94, 0.3)' 
        : status === 'maintenance' 
          ? 'rgba(234, 179, 8, 0.3)' 
          : status === 'cleaning'
            ? 'rgba(59, 130, 246, 0.3)'
            : 'rgba(255, 255, 255, 0.1)'
  }`,
  '&:hover': {
    background: status === 'occupied' 
      ? 'rgba(239, 68, 68, 0.25)' 
      : status === 'vacant' 
        ? 'rgba(34, 197, 94, 0.25)' 
        : status === 'maintenance' 
          ? 'rgba(234, 179, 8, 0.25)' 
          : status === 'cleaning'
            ? 'rgba(59, 130, 246, 0.25)'
            : 'rgba(255, 255, 255, 0.1)',
  }
}));

export const GlassDialog = styled(Dialog)(({ theme }) => ({
  '& .MuiDialog-paper': {
    background: 'rgba(0, 0, 0, 0.8)',
    backdropFilter: 'blur(30px)',
    color: 'white',
    borderRadius: '16px',
    border: '1px solid rgba(255, 255, 255, 0.05)',
  }
}));

export const PageTitle = styled(Typography)(({ theme }) => ({
  color: 'white',
  fontFamily: 'Lato',
  fontWeight: 500,
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
}));

export const InfoLabel = styled(Typography)(({ theme }) => ({
  color: 'rgba(255, 255, 255, 0.5)',
  fontSize: '0.875rem',
  fontFamily: 'Lato',
  fontWeight: 400,
  marginBottom: '4px',
  letterSpacing: '0.01em'
}));

export const InfoValue = styled(Typography)(({ theme }) => ({
  color: 'rgba(255, 255, 255, 0.9)',
  fontSize: '1rem',
  fontFamily: 'Lato',
  fontWeight: 400,
  letterSpacing: '0.01em'
}));

export const InfoContainer = styled(Box)(({ theme }) => ({
  padding: '16px',
  background: 'rgba(23, 23, 23, 0.95)',
  borderRadius: '16px',
  border: '1px solid rgba(255, 255, 255, 0.05)',
  transition: 'all 0.3s ease',
  '&:hover': {
    background: 'rgba(255, 255, 255, 0.05)',
  }
})); 