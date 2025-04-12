import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  LinearProgress,
  Chip,
  IconButton,
  Tooltip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Paper,
} from '@mui/material';
import { motion, AnimatePresence } from 'framer-motion';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, ResponsiveContainer, Area } from 'recharts';
import AddIcon from '@mui/icons-material/Add';
import CleaningServicesIcon from '@mui/icons-material/CleaningServices';
import BuildIcon from '@mui/icons-material/Build';
import EventAvailableIcon from '@mui/icons-material/EventAvailable';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import { styled } from '@mui/material/styles';
import { Grow } from '@mui/material';

const MotionBox = motion(Box);
const MotionCard = motion(Card);
const MotionTypography = motion(Typography);
const MotionChip = motion(Chip);

const cardVariants = {
  hidden: { 
    opacity: 0,
    y: 10
  },
  visible: { 
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.2,
      ease: 'easeOut'
    }
  }
};

const fadeIn = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      duration: 0.2,
      ease: 'easeOut'
    }
  }
};

const chipVariants = {
  hidden: { 
    opacity: 0,
    y: 5
  },
  visible: (i) => ({
    opacity: 1,
    y: 0,
    transition: {
      delay: i * 0.03,
      duration: 0.15,
      ease: 'easeOut'
    }
  }),
  tap: { 
    scale: 0.98,
    transition: {
      duration: 0.1
    }
  },
  hover: { 
    y: -1,
    transition: {
      duration: 0.1
    }
  }
};

const containerVariants = {
  hidden: { 
    opacity: 0
  },
  visible: {
    opacity: 1,
    transition: {
      duration: 0.2,
      staggerChildren: 0.05,
      ease: 'easeOut'
    }
  }
};

const filterRowVariants = {
  hidden: { 
    opacity: 0,
    y: -5
  },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.2,
      ease: 'easeOut'
    }
  }
};

const roomCardVariants = {
  hidden: { 
    opacity: 0
  },
  visible: (i) => ({
    opacity: 1,
    transition: {
      delay: i * 0.02,
      duration: 0.2
    }
  }),
  hover: {
    y: -2,
    transition: {
      duration: 0.15
    }
  },
  tap: {
    scale: 0.98,
    transition: {
      duration: 0.1
    }
  }
};

const RoomCard = styled(Paper)(({ status, roomType }) => ({
  padding: '12px',
  borderRadius: '12px',
  background: status === 'occupied' 
    ? roomType === 'Single'
      ? 'rgba(255, 192, 192, 0.15)'  // Lighter pink for Single rooms
      : 'rgba(40, 10, 10, 0.8)'      // Darker red/brown for Deluxe rooms
    : status === 'vacant' 
      ? 'rgba(34, 197, 94, 0.1)' 
      : status === 'maintenance' 
        ? 'rgba(234, 179, 8, 0.15)' 
        : 'rgba(59, 130, 246, 0.15)',
  backdropFilter: 'blur(10px)',
  border: `1px solid ${
    status === 'occupied' 
      ? roomType === 'Single'
        ? 'rgba(255, 192, 192, 0.3)'  // Lighter pink border for Single rooms
        : 'rgba(239, 68, 68, 0.3)'    // Red border for Deluxe rooms
      : status === 'vacant' 
        ? 'rgba(34, 197, 94, 0.3)' 
        : status === 'maintenance' 
          ? 'rgba(234, 179, 8, 0.3)' 
          : 'rgba(59, 130, 246, 0.3)'
  }`,
  cursor: 'pointer',
  transition: 'all 0.3s ease',
  '&:hover': {
    transform: 'translateY(-2px)',
    boxShadow: `0 4px 12px ${
      status === 'occupied' 
        ? roomType === 'Single'
          ? 'rgba(255, 192, 192, 0.2)'
          : 'rgba(239, 68, 68, 0.2)'
        : status === 'vacant' 
          ? 'rgba(34, 197, 94, 0.2)' 
          : status === 'maintenance' 
            ? 'rgba(234, 179, 8, 0.2)' 
            : 'rgba(59, 130, 246, 0.2)'
    }`,
  }
}));

const StatusChip = styled(Chip)(({ status, roomType }) => ({
  borderRadius: '16px',
  padding: '0 8px',
  height: '24px',
  fontFamily: 'Lato',
  fontWeight: 500,
  fontSize: '0.85rem',
  background: status === 'occupied' 
    ? roomType === 'Single'
      ? 'rgba(255, 192, 192, 0.15)'
      : 'rgba(40, 10, 10, 0.8)'
    : status === 'vacant' 
      ? 'rgba(34, 197, 94, 0.1)' 
      : status === 'maintenance' 
        ? 'rgba(234, 179, 8, 0.15)' 
        : status === 'cleaning'
          ? 'rgba(59, 130, 246, 0.15)'
          : status === 'forecast'
            ? 'rgba(33, 150, 243, 0.15)'
            : status === 'peak'
              ? 'rgba(239, 68, 68, 0.15)'
              : 'rgba(34, 197, 94, 0.15)',
  color: status === 'occupied' 
    ? roomType === 'Single'
      ? '#ff4444'
      : '#ff8888'
    : status === 'vacant' 
      ? 'rgb(34, 197, 94)' 
      : status === 'maintenance' 
        ? 'rgb(234, 179, 8)' 
        : status === 'cleaning'
          ? 'rgb(59, 130, 246)'
          : status === 'forecast'
            ? '#2196F3'
            : status === 'peak'
              ? '#ef4444'
              : '#22c55e',
  border: `1px solid ${
    status === 'occupied' 
      ? roomType === 'Single'
        ? 'rgba(255, 192, 192, 0.3)'
        : 'rgba(239, 68, 68, 0.3)'
      : status === 'vacant' 
        ? 'rgba(34, 197, 94, 0.3)' 
        : status === 'maintenance' 
          ? 'rgba(234, 179, 8, 0.3)' 
          : status === 'cleaning'
            ? 'rgba(59, 130, 246, 0.3)'
            : status === 'forecast'
              ? 'rgba(33, 150, 243, 0.3)'
              : status === 'peak'
                ? 'rgba(239, 68, 68, 0.3)'
                : 'rgba(34, 197, 94, 0.3)'
  }`,
  '&:hover': {
    background: status === 'occupied' 
      ? roomType === 'Single'
        ? 'rgba(255, 192, 192, 0.25)'
        : 'rgba(40, 10, 10, 0.9)'
      : status === 'vacant' 
        ? 'rgba(34, 197, 94, 0.2)' 
        : status === 'maintenance' 
          ? 'rgba(234, 179, 8, 0.25)' 
          : status === 'cleaning'
            ? 'rgba(59, 130, 246, 0.25)'
            : status === 'forecast'
              ? 'rgba(33, 150, 243, 0.25)'
              : status === 'peak'
                ? 'rgba(239, 68, 68, 0.25)'
                : 'rgba(34, 197, 94, 0.25)',
  }
}));

function OccupancyDashboard() {
  const [selectedDashboard, setSelectedDashboard] = useState('all');
  const [selectedRoomType, setSelectedRoomType] = useState('all');
  const [roomTypes, setRoomTypes] = useState([
    { 
      name: 'Single', 
      total: 20, 
      occupied: 15, 
      maintenance: 2, 
      cleaning: 1,
      rooms: Array(20).fill().map((_, i) => ({
        id: `single-${i + 1}`,
        number: i + 1,
        status: i < 15 ? 'occupied' : i < 17 ? 'maintenance' : i < 18 ? 'cleaning' : 'vacant'
      }))
    },
    { 
      name: 'Deluxe', 
      total: 15, 
      occupied: 10, 
      maintenance: 1, 
      cleaning: 2,
      rooms: Array(15).fill().map((_, i) => ({
        id: `deluxe-${i + 1}`,
        number: i + 1,
        status: i < 10 ? 'occupied' : i < 11 ? 'maintenance' : i < 13 ? 'cleaning' : 'vacant'
      }))
    },
    { 
      name: 'Suite', 
      total: 10, 
      occupied: 8, 
      maintenance: 0, 
      cleaning: 1,
      rooms: Array(10).fill().map((_, i) => ({
        id: `suite-${i + 1}`,
        number: i + 1,
        status: i < 8 ? 'occupied' : i < 9 ? 'cleaning' : 'vacant'
      }))
    },
    { 
      name: 'Premium Suite', 
      total: 5, 
      occupied: 4, 
      maintenance: 0, 
      cleaning: 0,
      rooms: Array(5).fill().map((_, i) => ({
        id: `premium-${i + 1}`,
        number: i + 1,
        status: i < 4 ? 'occupied' : 'vacant'
      }))
    }
  ]);

  const [forecastType, setForecastType] = useState('weekly');
  const [weeklyForecastData, setWeeklyForecastData] = useState([
    { day: 'Mon', occupancy: 65 },
    { day: 'Tue', occupancy: 70 },
    { day: 'Wed', occupancy: 75 },
    { day: 'Thu', occupancy: 80 },
    { day: 'Fri', occupancy: 85 },
    { day: 'Sat', occupancy: 90 },
    { day: 'Sun', occupancy: 95 }
  ]);

  const [monthlyForecastData, setMonthlyForecastData] = useState([
    { month: 'Jan', occupancy: 72 },
    { month: 'Feb', occupancy: 75 },
    { month: 'Mar', occupancy: 80 },
    { month: 'Apr', occupancy: 85 },
    { month: 'May', occupancy: 88 },
    { month: 'Jun', occupancy: 92 },
    { month: 'Jul', occupancy: 95 },
    { month: 'Aug', occupancy: 94 },
    { month: 'Sep', occupancy: 89 },
    { month: 'Oct', occupancy: 83 },
    { month: 'Nov', occupancy: 78 },
    { month: 'Dec', occupancy: 85 }
  ]);

  const [yearlyForecastData, setYearlyForecastData] = useState([
    { year: '2020', occupancy: 75 },
    { year: '2021', occupancy: 78 },
    { year: '2022', occupancy: 82 },
    { year: '2023', occupancy: 85 },
    { year: '2024', occupancy: 88 },
    { year: '2025', occupancy: 90 }
  ]);

  const [openDialog, setOpenDialog] = useState(false);
  const [newRoomType, setNewRoomType] = useState({ name: '', total: '' });

  const calculateOccupancyRate = (roomType) => {
    return Math.round((roomType.occupied / roomType.total) * 100);
  };

  const calculateUtilizationRate = (roomType) => {
    const available = roomType.total - roomType.maintenance - roomType.cleaning;
    return Math.round((roomType.occupied / available) * 100);
  };

  const handleAddRoomType = () => {
    if (newRoomType.name && newRoomType.total && Number(newRoomType.total) > 0) {
      const newType = { 
        name: newRoomType.name, 
        total: Number(newRoomType.total),
        occupied: 0,
        maintenance: 0,
        cleaning: 0,
        rooms: Array(Number(newRoomType.total)).fill().map((_, i) => ({
          id: `${newRoomType.name.toLowerCase()}-${i + 1}`,
          number: i + 1,
          status: 'vacant'
        }))
      };
      
      setRoomTypes(prevTypes => [...prevTypes, newType]);
      setNewRoomType({ name: '', total: '' });
      setOpenDialog(false);
    }
  };

  const handleRoomStatusChange = (roomTypeIndex, roomIndex) => {
    const newRoomTypes = [...roomTypes];
    const room = newRoomTypes[roomTypeIndex].rooms[roomIndex];
    
    // Animate the status change
    const statusOrder = ['vacant', 'occupied', 'maintenance', 'cleaning'];
    const currentIndex = statusOrder.indexOf(room.status);
    const nextStatus = statusOrder[(currentIndex + 1) % statusOrder.length];
    
    // Update with animation
    room.status = nextStatus;
    
    // Update counts with smooth transition
    const counts = newRoomTypes[roomTypeIndex].rooms.reduce((acc, r) => {
      acc[r.status]++;
      return acc;
    }, { occupied: 0, maintenance: 0, cleaning: 0 });
    
    newRoomTypes[roomTypeIndex] = {
      ...newRoomTypes[roomTypeIndex],
      occupied: counts.occupied,
      maintenance: counts.maintenance,
      cleaning: counts.cleaning
    };
    
    setRoomTypes(newRoomTypes);
  };

  const dashboardOptions = [
    { value: 'all', label: 'All Rooms' },
    { value: 'occupied', label: 'Occupied' },
    { value: 'vacant', label: 'Vacant' },
    { value: 'maintenance', label: 'Maintenance' },
    { value: 'cleaning', label: 'Cleaning' }
  ];

  const filteredRoomTypes = roomTypes
    .filter(roomType => 
      selectedRoomType === 'all' ? true : roomType.name.toLowerCase() === selectedRoomType.toLowerCase()
    )
    .map(roomType => ({
      ...roomType,
      rooms: roomType.rooms.filter(room => 
        selectedDashboard === 'all' ? true : room.status === selectedDashboard
      )
    }));

  return (
    <MotionBox
      initial="hidden"
      animate="visible"
      variants={fadeIn}
      sx={{ 
        maxWidth: '1400px',
        mx: 'auto',
        px: 2
      }}
    >
      <Box sx={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        mb: 4 
      }}>
        <MotionTypography 
          variant="h4" 
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          sx={{ 
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
          }}
        >
          Real-time Occupancy Dashboard
        </MotionTypography>

        <Tooltip title="Add Hotel Room">
          <IconButton 
            onClick={() => setOpenDialog(true)}
            sx={{ 
              color: 'white',
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
              borderRadius: '12px',
              '&:hover': {
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
              }
            }}
          >
            <AddIcon />
          </IconButton>
        </Tooltip>
      </Box>

      <Box 
        sx={{ 
          display: 'flex', 
          flexDirection: 'column',
          gap: 2,
          mb: 3,
        }}
      >
        <MotionBox
          variants={filterRowVariants}
          initial="hidden"
          animate="visible"
          sx={{ 
            display: 'flex', 
            gap: 1, 
            overflowX: 'auto',
            pb: 1,
            '&::-webkit-scrollbar': {
              height: '6px',
            },
            '&::-webkit-scrollbar-track': {
              background: 'rgba(255, 255, 255, 0.05)',
              borderRadius: '10px',
            },
            '&::-webkit-scrollbar-thumb': {
              background: 'rgba(255, 255, 255, 0.1)',
              borderRadius: '10px',
              '&:hover': {
                background: 'rgba(255, 255, 255, 0.2)',
              },
            },
          }}
        >
          <AnimatePresence mode="wait">
            {dashboardOptions.map((option, index) => (
              <MotionChip
                key={option.value}
                custom={index}
                variants={chipVariants}
                initial="hidden"
                animate="visible"
                whileHover="hover"
                whileTap="tap"
                label={option.label}
                onClick={() => setSelectedDashboard(option.value)}
                sx={{
                  backgroundColor: selectedDashboard === option.value 
                    ? 'rgba(255, 255, 255, 0.15)' 
                    : 'rgba(255, 255, 255, 0.05)',
                  color: 'white',
                  border: '1px solid',
                  borderColor: selectedDashboard === option.value 
                    ? 'rgba(255, 255, 255, 0.5)' 
                    : 'rgba(255, 255, 255, 0.1)',
                  '&:hover': {
                    backgroundColor: 'rgba(255, 255, 255, 0.1)',
                  },
                  transition: 'all 0.3s ease',
                  fontFamily: 'Lato',
                  px: 1,
                }}
              />
            ))}
          </AnimatePresence>
        </MotionBox>

        <MotionBox
          variants={filterRowVariants}
          initial="hidden"
          animate="visible"
          sx={{ 
            display: 'flex', 
            gap: 1, 
            overflowX: 'auto',
            pb: 1,
            '&::-webkit-scrollbar': {
              height: '6px',
            },
            '&::-webkit-scrollbar-track': {
              background: 'rgba(255, 255, 255, 0.05)',
              borderRadius: '10px',
            },
            '&::-webkit-scrollbar-thumb': {
              background: 'rgba(255, 255, 255, 0.1)',
              borderRadius: '10px',
              '&:hover': {
                background: 'rgba(255, 255, 255, 0.2)',
              },
            },
          }}
        >
          <AnimatePresence mode="wait">
            <MotionChip
              key="all-types"
              custom={0}
              variants={chipVariants}
              initial="hidden"
              animate="visible"
              whileHover="hover"
              whileTap="tap"
              label="All Types"
              onClick={() => setSelectedRoomType('all')}
              sx={{
                backgroundColor: selectedRoomType === 'all' 
                  ? 'rgba(255, 255, 255, 0.15)' 
                  : 'rgba(255, 255, 255, 0.05)',
                color: 'white',
                border: '1px solid',
                borderColor: selectedRoomType === 'all' 
                  ? 'rgba(255, 255, 255, 0.5)' 
                  : 'rgba(255, 255, 255, 0.1)',
                '&:hover': {
                  backgroundColor: 'rgba(255, 255, 255, 0.1)',
                },
                transition: 'all 0.3s ease',
                fontFamily: 'Lato',
                px: 1,
              }}
            />
            {roomTypes.map((type, index) => (
              <MotionChip
                key={type.name}
                custom={index + 1}
                variants={chipVariants}
                initial="hidden"
                animate="visible"
                whileHover="hover"
                whileTap="tap"
                label={type.name}
                onClick={() => setSelectedRoomType(type.name)}
                sx={{
                  backgroundColor: selectedRoomType === type.name 
                    ? 'rgba(255, 255, 255, 0.15)' 
                    : 'rgba(255, 255, 255, 0.05)',
                  color: 'white',
                  border: '1px solid',
                  borderColor: selectedRoomType === type.name 
                    ? 'rgba(255, 255, 255, 0.5)' 
                    : 'rgba(255, 255, 255, 0.1)',
                  '&:hover': {
                    backgroundColor: 'rgba(255, 255, 255, 0.1)',
                  },
                  transition: 'all 0.3s ease',
                  fontFamily: 'Lato',
                  px: 1,
                }}
              />
            ))}
          </AnimatePresence>
        </MotionBox>
      </Box>

      <AnimatePresence mode="wait">
        <motion.div
          layout
          initial={{ opacity: 0, filter: 'blur(10px)' }}
          animate={{ opacity: 1, filter: 'blur(0px)' }}
          exit={{ opacity: 0, filter: 'blur(10px)' }}
          transition={{
            duration: 0.4,
            ease: [0.22, 1, 0.36, 1]
          }}
        >
          <Grid container spacing={2}>
            {filteredRoomTypes.map((roomType, roomTypeIndex) => (
              <Grid item xs={12} key={roomType.name}>
                <MotionCard
                  variants={cardVariants}
                  sx={{
                    background: 'rgba(0, 0, 0, 0.3)', // Darker background to match image
                    backdropFilter: 'blur(20px)',
                    border: '1px solid rgba(255, 255, 255, 0.05)',
                    borderRadius: '16px',
                    transition: 'all 0.3s ease',
                    boxShadow: '0 4px 24px rgba(0, 0, 0, 0.2)',
                  }}
                >
                  <CardContent sx={{ p: 2 }}> {/* Reduced padding */}
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                      <Typography variant="h6" sx={{ color: 'white', fontFamily: 'Lato', fontSize: '1.25rem' }}>
                        {roomType.name} Rooms
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 0.75 }}> {/* Reduced gap between chips */}
                        <StatusChip
                          icon={<CancelIcon sx={{ fontSize: '1rem' }} />}
                          label={`${roomType.occupied} Occupied`}
                          status="occupied"
                          roomType={roomType.name}
                        />
                        <StatusChip
                          icon={<CheckCircleIcon sx={{ fontSize: '1rem' }} />}
                          label={`${roomType.total - roomType.occupied - roomType.maintenance - roomType.cleaning} Vacant`}
                          status="vacant"
                          roomType={roomType.name}
                        />
                        <StatusChip
                          icon={<BuildIcon sx={{ fontSize: '1rem' }} />}
                          label={`${roomType.maintenance} Maintenance`}
                          status="maintenance"
                          roomType={roomType.name}
                        />
                        <StatusChip
                          icon={<CleaningServicesIcon sx={{ fontSize: '1rem' }} />}
                          label={`${roomType.cleaning} Cleaning`}
                          status="cleaning"
                          roomType={roomType.name}
                        />
                      </Box>
                    </Box>

                    <Grid container spacing={1.5}> {/* Reduced grid spacing */}
                      {roomType.rooms.map((room, roomIndex) => (
                        <Grid item xs={6} sm={3} md={2} lg={1.5} key={room.id}> {/* Adjusted grid sizes */}
                          <motion.div
                            variants={roomCardVariants}
                            custom={roomIndex}
                            initial="hidden"
                            animate="visible"
                            whileHover="hover"
                            whileTap="tap"
                          >
                            <RoomCard
                              status={room.status}
                              roomType={roomType.name}
                              onClick={() => handleRoomStatusChange(roomTypeIndex, roomIndex)}
                            >
                              <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 0.5 }}>
                                <Typography
                                  variant="h6"
                                  sx={{
                                    color: room.status === 'occupied' 
                                      ? roomType.name === 'Single'
                                        ? '#ff4444'
                                        : '#ff8888'
                                      : room.status === 'vacant' 
                                        ? 'rgb(34, 197, 94)' 
                                        : room.status === 'maintenance' 
                                          ? 'rgb(234, 179, 8)' 
                                          : 'rgb(59, 130, 246)',
                                    fontFamily: 'Lato',
                                    fontWeight: 500,
                                    fontSize: '1rem'
                                  }}
                                >
                                  Room {room.number}
                                </Typography>
                                <Typography
                                  variant="body2"
                                  sx={{
                                    color: room.status === 'occupied' 
                                      ? roomType.name === 'Single'
                                        ? '#ff4444'
                                        : '#ff8888'
                                      : room.status === 'vacant' 
                                        ? 'rgba(34, 197, 94, 0.8)' 
                                        : room.status === 'maintenance' 
                                          ? 'rgba(234, 179, 8, 0.8)' 
                                          : 'rgba(59, 130, 246, 0.8)',
                                    fontFamily: 'Lato',
                                    textTransform: 'capitalize',
                                    fontSize: '0.85rem'
                                  }}
                                >
                                  {room.status}
                                </Typography>
                              </Box>
                            </RoomCard>
                          </motion.div>
                        </Grid>
                      ))}
                    </Grid>
                  </CardContent>
                </MotionCard>
              </Grid>
            ))}

            <Grid item xs={12}>
              <MotionCard
                variants={cardVariants}
                whileHover="hover"
                initial="hidden"
                animate="visible"
                sx={{
                  background: 'rgba(0, 0, 0, 0.3)',
                  backdropFilter: 'blur(20px)',
                  border: '1px solid rgba(255, 255, 255, 0.05)',
                  borderRadius: '16px',
                  transition: 'all 0.4s cubic-bezier(0.22, 1, 0.36, 1)',
                  boxShadow: '0 4px 24px rgba(0, 0, 0, 0.2)',
                  '&:hover': {
                    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    background: 'rgba(0, 0, 0, 0.4)',
                  }
                }}
              >
                <CardContent sx={{ p: 2 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                      <Typography variant="h6" sx={{ color: 'white', fontFamily: 'Lato', fontSize: '1.25rem' }}>
                        Occupancy Forecast
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 1 }}>
                        <AnimatePresence mode="wait">
                          {['weekly', 'monthly', 'yearly'].map((type, index) => (
                            <MotionChip
                              key={type}
                              custom={index}
                              variants={chipVariants}
                              initial="hidden"
                              animate="visible"
                              whileHover="hover"
                              whileTap="tap"
                              icon={<EventAvailableIcon sx={{ fontSize: '1rem' }} />}
                              label={type.charAt(0).toUpperCase() + type.slice(1)}
                              status={forecastType === type ? 'forecast' : undefined}
                              roomType="forecast"
                              onClick={() => setForecastType(type)}
                              sx={{ cursor: 'pointer' }}
                            />
                          ))}
                        </AnimatePresence>
                      </Box>
                    </Box>
                    <Box sx={{ display: 'flex', gap: 0.75 }}>
                      <StatusChip
                        label="Peak Days"
                        status="peak"
                        roomType="forecast"
                      />
                      <StatusChip
                        label="Low Days"
                        status="low"
                        roomType="forecast"
                      />
                    </Box>
                  </Box>

                  <Box sx={{ height: 300, mt: 2, p: 2, background: 'rgba(0, 0, 0, 0.2)', borderRadius: '12px' }}>
                    <ResponsiveContainer width="100%" height="100%">
                      <LineChart 
                        data={
                          forecastType === 'weekly' 
                            ? weeklyForecastData 
                            : forecastType === 'monthly' 
                              ? monthlyForecastData 
                              : yearlyForecastData
                        } 
                        margin={{ top: 10, right: 10, left: 10, bottom: 10 }}
                      >
                        <defs>
                          <linearGradient id="occupancyGradient" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%" stopColor="#ffffff" stopOpacity={0.3}/>
                            <stop offset="95%" stopColor="#ffffff" stopOpacity={0.05}/>
                          </linearGradient>
                        </defs>
                        <CartesianGrid 
                          strokeDasharray="3 3" 
                          stroke="rgba(255, 255, 255, 0.1)"
                          horizontal={true}
                          vertical={false}
                        />
                        <XAxis 
                          dataKey={
                            forecastType === 'weekly' 
                              ? 'day' 
                              : forecastType === 'monthly' 
                                ? 'month' 
                                : 'year'
                          }
                          stroke="#fff"
                          tick={{ fill: '#fff', fontSize: 12, fontFamily: 'Lato' }}
                          axisLine={{ stroke: 'rgba(255, 255, 255, 0.3)' }}
                          tickLine={{ stroke: 'rgba(255, 255, 255, 0.3)' }}
                        />
                        <YAxis 
                          stroke="#fff"
                          tick={{ fill: '#fff', fontSize: 12, fontFamily: 'Lato' }}
                          axisLine={{ stroke: 'rgba(255, 255, 255, 0.3)' }}
                          tickLine={{ stroke: 'rgba(255, 255, 255, 0.3)' }}
                          domain={[0, 100]}
                          ticks={[0, 20, 40, 60, 80, 100]}
                        />
                        <RechartsTooltip
                          content={({ active, payload, label }) => {
                            if (active && payload && payload.length) {
                              return (
                                <Box
                                  sx={{
                                    background: 'rgba(0, 0, 0, 0.95)',
                                    border: '1px solid #fff',
                                    borderRadius: '4px',
                                    p: 1,
                                  }}
                                >
                                  <Typography sx={{ color: '#fff', fontFamily: 'Lato', fontSize: '0.875rem' }}>
                                    {label}: {payload[0].value}% Occupancy
                                  </Typography>
                                </Box>
                              );
                            }
                            return null;
                          }}
                        />
                        <Line
                          type="monotone"
                          dataKey="occupancy"
                          stroke="#fff"
                          strokeWidth={2}
                          dot={{ 
                            fill: '#000',
                            stroke: '#fff',
                            strokeWidth: 2,
                            r: 4
                          }}
                          activeDot={{ 
                            r: 6, 
                            fill: '#000',
                            stroke: '#fff',
                            strokeWidth: 2
                          }}
                        />
                      </LineChart>
                    </ResponsiveContainer>
                  </Box>
                </CardContent>
              </MotionCard>
            </Grid>
          </Grid>
        </motion.div>
      </AnimatePresence>

      <Dialog
        open={openDialog}
        onClose={() => setOpenDialog(false)}
        TransitionComponent={Grow}
        TransitionProps={{
          timeout: 400,
          easing: "cubic-bezier(0.22, 1, 0.36, 1)"
        }}
        PaperProps={{
          sx: {
            background: 'rgba(255, 255, 255, 0.03)',
            backdropFilter: 'blur(20px)',
            border: '1px solid rgba(255, 255, 255, 0.05)',
            borderRadius: '20px',
            color: 'white',
            transform: 'scale(1)',
            transition: 'all 0.4s cubic-bezier(0.22, 1, 0.36, 1)',
            '&:hover': {
              boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)',
            }
          }
        }}
      >
        <DialogTitle sx={{ fontFamily: 'Lato' }}>Add New Room Type</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Room Type Name"
            fullWidth
            value={newRoomType.name}
            onChange={(e) => setNewRoomType({ ...newRoomType, name: e.target.value })}
            sx={{
              mb: 2,
              '& .MuiOutlinedInput-root': {
                color: 'white',
                '& fieldset': {
                  borderColor: 'rgba(255, 255, 255, 0.2)',
                },
                '&:hover fieldset': {
                  borderColor: 'rgba(255, 255, 255, 0.3)',
                },
                '&.Mui-focused fieldset': {
                  borderColor: 'white',
                },
              },
              '& .MuiInputLabel-root': {
                color: 'rgba(255, 255, 255, 0.7)',
              },
            }}
          />
          <TextField
            margin="dense"
            label="Total Rooms"
            type="number"
            fullWidth
            value={newRoomType.total}
            onChange={(e) => setNewRoomType({ ...newRoomType, total: e.target.value })}
            InputProps={{ inputProps: { min: 0 } }}
            sx={{
              '& .MuiOutlinedInput-root': {
                color: 'white',
                '& fieldset': {
                  borderColor: 'rgba(255, 255, 255, 0.2)',
                },
                '&:hover fieldset': {
                  borderColor: 'rgba(255, 255, 255, 0.3)',
                },
                '&.Mui-focused fieldset': {
                  borderColor: 'white',
                },
              },
              '& .MuiInputLabel-root': {
                color: 'rgba(255, 255, 255, 0.7)',
              },
            }}
          />
        </DialogContent>
        <DialogActions>
          <Button 
            onClick={() => setOpenDialog(false)}
            sx={{ 
              color: 'rgba(255, 255, 255, 0.7)',
              '&:hover': {
                color: 'white',
              }
            }}
          >
            Cancel
          </Button>
          <Button 
            onClick={handleAddRoomType}
            disabled={!newRoomType.name || !newRoomType.total || Number(newRoomType.total) <= 0}
            sx={{ 
              color: 'white',
              '&:hover': {
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
              }
            }}
          >
            Add
          </Button>
        </DialogActions>
      </Dialog>
    </MotionBox>
  );
}

export default OccupancyDashboard; 