import React, { useState } from 'react';
import {
  Box,
  Typography,
  Grid,
  CardContent,
  IconButton,
  Tooltip,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Grow,
  Paper
} from '@mui/material';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, ResponsiveContainer } from 'recharts';
import AddIcon from '@mui/icons-material/Add';
import CleaningServicesIcon from '@mui/icons-material/CleaningServices';
import BuildIcon from '@mui/icons-material/Build';
import EventAvailableIcon from '@mui/icons-material/EventAvailable';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';

// Import common components
import { 
  GlassCard,
  GlassButton,
  GlassChip,
  GlassDialog,
  PageTitle
} from '../components/common/StyledComponents';

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
  const [weeklyForecastData] = useState([
    { day: 'Mon', occupancy: 65 },
    { day: 'Tue', occupancy: 70 },
    { day: 'Wed', occupancy: 75 },
    { day: 'Thu', occupancy: 80 },
    { day: 'Fri', occupancy: 85 },
    { day: 'Sat', occupancy: 90 },
    { day: 'Sun', occupancy: 95 }
  ]);

  const [monthlyForecastData] = useState([
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

  const [yearlyForecastData] = useState([
    { year: '2020', occupancy: 75 },
    { year: '2021', occupancy: 78 },
    { year: '2022', occupancy: 82 },
    { year: '2023', occupancy: 85 },
    { year: '2024', occupancy: 88 },
    { year: '2025', occupancy: 90 }
  ]);

  const [openDialog, setOpenDialog] = useState(false);
  const [newRoomType, setNewRoomType] = useState({ name: '', total: '' });

  // eslint-disable-next-line no-unused-vars
  const calculateOccupancyRate = (roomType) => {
    return Math.round((roomType.occupied / roomType.total) * 100);
  };

  // eslint-disable-next-line no-unused-vars
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

  const getRoomStyle = (status, roomType) => {
    const styles = {
      occupied: {
        background: 'rgba(65, 25, 25, 0.7)',
        border: '1px solid rgba(235, 100, 100, 0.3)',
        color: '#e88a8a',
        boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1), inset 0 1px rgba(255, 255, 255, 0.1)'
      },
      vacant: {
        background: 'rgba(25, 65, 25, 0.6)',
        border: '1px solid rgba(100, 235, 100, 0.3)',
        color: '#7ed37e',
        boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1), inset 0 1px rgba(255, 255, 255, 0.1)'
      },
      maintenance: {
        background: 'rgba(65, 55, 20, 0.6)',
        border: '1px solid rgba(235, 180, 50, 0.3)',
        color: '#e6c160',
        boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1), inset 0 1px rgba(255, 255, 255, 0.1)'
      },
      cleaning: {
        background: 'rgba(25, 35, 65, 0.6)',
        border: '1px solid rgba(100, 150, 235, 0.3)',
        color: '#7ea5e8',
        boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1), inset 0 1px rgba(255, 255, 255, 0.1)'
      }
    };

    return styles[status] || styles.vacant;
  };

  return (
    <Box sx={{ maxWidth: '1400px', mx: 'auto', px: 2 }}>
      <Box sx={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        mb: 4 
      }}>
        <PageTitle variant="h4">
          Real-time Occupancy Dashboard
        </PageTitle>

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
        <Box
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
          {dashboardOptions.map((option, index) => (
            <GlassChip
              key={option.value}
              label={option.label}
              onClick={() => setSelectedDashboard(option.value)}
              status={selectedDashboard === option.value ? 'selected' : undefined}
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
        </Box>

        <Box
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
          <GlassChip
            label="All Types"
            onClick={() => setSelectedRoomType('all')}
            status={selectedRoomType === 'all' ? 'selected' : undefined}
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
            <GlassChip
              key={type.name}
              label={type.name}
              onClick={() => setSelectedRoomType(type.name)}
              status={selectedRoomType === type.name ? 'selected' : undefined}
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
        </Box>
      </Box>

      <Grid container spacing={2}>
        {filteredRoomTypes.map((roomType, roomTypeIndex) => (
          <Grid item xs={12} key={roomType.name}>
            <GlassCard>
              <CardContent sx={{ p: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                  <Typography variant="h6" sx={{ color: 'white', fontFamily: 'Lato', fontSize: '1.25rem' }}>
                    {roomType.name} Rooms
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 0.75 }}>
                    <GlassChip
                      icon={<CancelIcon sx={{ fontSize: '1rem' }} />}
                      label={`${roomType.occupied} Occupied`}
                      status="occupied"
                    />
                    <GlassChip
                      icon={<CheckCircleIcon sx={{ fontSize: '1rem' }} />}
                      label={`${roomType.total - roomType.occupied - roomType.maintenance - roomType.cleaning} Vacant`}
                      status="vacant"
                    />
                    <GlassChip
                      icon={<BuildIcon sx={{ fontSize: '1rem' }} />}
                      label={`${roomType.maintenance} Maintenance`}
                      status="maintenance"
                    />
                    <GlassChip
                      icon={<CleaningServicesIcon sx={{ fontSize: '1rem' }} />}
                      label={`${roomType.cleaning} Cleaning`}
                      status="cleaning"
                    />
                  </Box>
                </Box>

                <Grid container spacing={1.5}>
                  {roomType.rooms.map((room, roomIndex) => (
                    <Grid item xs={6} sm={3} md={2} lg={1.5} key={room.id}>
                      <Paper
                        onClick={() => handleRoomStatusChange(roomTypeIndex, roomIndex)}
                        sx={{
                          padding: '12px',
                          cursor: 'pointer',
                          borderRadius: '8px',
                          ...getRoomStyle(room.status, roomType.name),
                          transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)',
                          transform: 'translateY(0)',
                          '&:hover': {
                            transform: 'translateY(-2px)',
                            boxShadow: (theme) => `0 4px 8px rgba(0, 0, 0, 0.2), inset 0 1px rgba(255, 255, 255, 0.15)`,
                            filter: 'brightness(1.1)'
                          },
                          '&:active': {
                            transform: 'translateY(0)',
                            filter: 'brightness(0.95)',
                            transition: 'all 0.1s cubic-bezier(0.4, 0, 0.2, 1)'
                          }
                        }}
                      >
                        <Box 
                          sx={{ 
                            display: 'flex', 
                            flexDirection: 'column', 
                            alignItems: 'center', 
                            gap: 0.5,
                            '@keyframes fadeIn': {
                              '0%': {
                                opacity: 0,
                                transform: 'translateY(5px)'
                              },
                              '100%': {
                                opacity: 1,
                                transform: 'translateY(0)'
                              }
                            },
                            animation: 'fadeIn 0.3s ease-out'
                          }}
                        >
                          <Typography
                            variant="h6"
                            sx={{
                              color: 'inherit',
                              fontFamily: 'Lato',
                              fontWeight: 500,
                              fontSize: '1rem',
                              textShadow: '0 1px 2px rgba(0, 0, 0, 0.2)'
                            }}
                          >
                            Room {room.number}
                          </Typography>
                          <Typography
                            variant="body2"
                            sx={{
                              color: 'inherit',
                              fontFamily: 'Lato',
                              textTransform: 'capitalize',
                              fontSize: '0.85rem',
                              opacity: 0.9,
                              textShadow: '0 1px 2px rgba(0, 0, 0, 0.2)'
                            }}
                          >
                            {room.status}
                          </Typography>
                        </Box>
                      </Paper>
                    </Grid>
                  ))}
                </Grid>
              </CardContent>
            </GlassCard>
          </Grid>
        ))}

        <Grid item xs={12}>
          <GlassCard>
            <CardContent sx={{ p: 2 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                  <Typography variant="h6" sx={{ color: 'white', fontFamily: 'Lato', fontSize: '1.25rem' }}>
                    Occupancy Forecast
                  </Typography>
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    {['weekly', 'monthly', 'yearly'].map((type, index) => (
                      <GlassChip
                        key={type}
                        icon={<EventAvailableIcon sx={{ fontSize: '1rem' }} />}
                        label={type.charAt(0).toUpperCase() + type.slice(1)}
                        status={forecastType === type ? 'forecast' : undefined}
                        onClick={() => setForecastType(type)}
                        sx={{ cursor: 'pointer' }}
                      />
                    ))}
                  </Box>
                </Box>
                <Box sx={{ display: 'flex', gap: 0.75 }}>
                  <GlassChip
                    label="Peak Days"
                    status="peak"
                  />
                  <GlassChip
                    label="Low Days"
                    status="low"
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
          </GlassCard>
        </Grid>
      </Grid>

      <GlassDialog
        open={openDialog}
        onClose={() => setOpenDialog(false)}
        TransitionComponent={Grow}
        TransitionProps={{
          timeout: 400,
          easing: "cubic-bezier(0.22, 1, 0.36, 1)"
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
      </GlassDialog>
    </Box>
  );
}

export default OccupancyDashboard; 