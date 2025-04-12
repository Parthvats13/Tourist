import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Chip,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Paper,
  Grid,
  Divider,
  Rating,
  Avatar,
  Card,
  CardContent,
  CircularProgress,
} from '@mui/material';
import { motion, AnimatePresence } from 'framer-motion';
import EditIcon from '@mui/icons-material/Edit';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import HotelIcon from '@mui/icons-material/Hotel';
import WifiIcon from '@mui/icons-material/Wifi';
import PoolIcon from '@mui/icons-material/Pool';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import SpaIcon from '@mui/icons-material/Spa';
import MeetingRoomIcon from '@mui/icons-material/MeetingRoom';
import SportsHandballIcon from '@mui/icons-material/SportsHandball';
import LocalParkingIcon from '@mui/icons-material/LocalParking';
import RoomServiceIcon from '@mui/icons-material/RoomService';
import LandscapeIcon from '@mui/icons-material/Landscape';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import StarHalfIcon from '@mui/icons-material/StarHalf';

const MotionBox = motion(Box);
const MotionPaper = motion(Paper);
const MotionTypography = motion(Typography);
const MotionCard = motion(Card);

const fadeInUp = {
  initial: { opacity: 0, y: 10 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -10 },
  transition: { duration: 0.4 }
};

const staggerChildren = {
  animate: {
    transition: {
      staggerChildren: 0.05
    }
  }
};

const DEFAULT_HOTEL_DATA = {
  name: 'Mountain View Resort & Spa',
  description: 'Nestled in the heart of Himachal Pradesh, our resort offers breathtaking views of the snow-capped mountains and luxurious amenities for an unforgettable stay.',
  features: [
    'Mountain View Rooms',
    'Luxury Spa',
    'Infinity Pool',
    '24/7 Room Service',
    'Fine Dining Restaurant',
    'Adventure Activities',
    'Conference Facilities',
    'WiFi',
    'Parking'
  ],
  location: 'Manali, Himachal Pradesh',
  rating: 4.5,
  reviews: 128,
  price: 8500,
  host: {
    name: 'Rajesh Kumar',
    avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
    joined: 'January 2020',
    responseRate: '99%',
  },
};

const AppView = () => {
  const [hotelData, setHotelData] = useState(DEFAULT_HOTEL_DATA);
  const [editData, setEditData] = useState({ ...DEFAULT_HOTEL_DATA });
  const [open, setOpen] = useState(false);

  const handleEdit = () => setOpen(true);
  const handleClose = () => setOpen(false);
  const handleSave = () => {
    setHotelData(editData);
    setOpen(false);
  };

  const handleFeatureChange = (event) => {
    const features = event.target.value.split(',').map(feature => feature.trim());
    setEditData({ ...editData, features });
  };

  const getFeatureIcon = (feature) => {
    const featureLower = feature.toLowerCase();
    if (featureLower.includes('ac') || featureLower.includes('room')) return <HotelIcon />;
    if (featureLower.includes('wifi')) return <WifiIcon />;
    if (featureLower.includes('pool')) return <PoolIcon />;
    if (featureLower.includes('restaurant')) return <RestaurantIcon />;
    if (featureLower.includes('spa')) return <SpaIcon />;
    if (featureLower.includes('conference')) return <MeetingRoomIcon />;
    if (featureLower.includes('adventure')) return <SportsHandballIcon />;
    if (featureLower.includes('parking')) return <LocalParkingIcon />;
    if (featureLower.includes('service')) return <RoomServiceIcon />;
    if (featureLower.includes('mountain') || featureLower.includes('view')) return <LandscapeIcon />;
    return <HotelIcon />;
  };

  const renderStars = (rating) => {
    const stars = [];
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 !== 0;

    for (let i = 0; i < fullStars; i++) {
      stars.push(<StarIcon key={`star-${i}`} sx={{ color: '#FFD700' }} />);
    }

    if (hasHalfStar) {
      stars.push(<StarHalfIcon key="half-star" sx={{ color: '#FFD700' }} />);
    }

    const emptyStars = 5 - stars.length;
    for (let i = 0; i < emptyStars; i++) {
      stars.push(<StarBorderIcon key={`empty-star-${i}`} sx={{ color: '#FFD700' }} />);
    }

    return stars;
  };

  return (
    <AnimatePresence mode="wait">
      <MotionBox
        key="app-view"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.3 }}
        sx={{ 
          p: { xs: 2, md: 3 }, 
          color: 'white',
          minHeight: '100vh',
          width: '100%',
          position: 'relative',
          zIndex: 1
        }}
      >
        <MotionPaper 
          elevation={0}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
          sx={{ 
            p: { xs: 2, md: 3 }, 
            maxWidth: 1200, 
            mx: 'auto',
            background: 'rgba(18, 18, 18, 0.95)',
            backdropFilter: 'blur(10px)',
            border: '1px solid rgba(255, 255, 255, 0.05)',
            borderRadius: 2,
            position: 'relative',
            zIndex: 2
          }}
        >
          <MotionBox 
            {...fadeInUp}
            sx={{ 
              display: 'flex', 
              justifyContent: 'space-between', 
              alignItems: 'center', 
              mb: 4 
            }}
          >
            <MotionTypography 
              variant="h4" 
              component="h1" 
              sx={{ 
                fontWeight: 500,
                letterSpacing: '-0.02em',
                color: 'white'
              }}
            >
              {hotelData.name}
            </MotionTypography>
            <Button
              variant="outlined"
              startIcon={<EditIcon />}
              onClick={handleEdit}
              sx={{ 
                borderColor: 'rgba(255, 255, 255, 0.1)',
                color: 'white',
                '&:hover': {
                  borderColor: 'rgba(255, 255, 255, 0.2)',
                  background: 'rgba(255, 255, 255, 0.02)',
                },
                textTransform: 'none',
                px: 2,
              }}
            >
              Edit Profile
            </Button>
          </MotionBox>

          <Grid container spacing={4}>
            <Grid item xs={12} md={8}>
              <MotionBox variants={staggerChildren} initial="initial" animate="animate">
                <MotionBox {...fadeInUp} sx={{ mb: 4 }}>
                  <Box sx={{ 
                    display: 'flex', 
                    alignItems: 'center', 
                    mb: 2,
                    flexWrap: 'wrap',
                    gap: 2
                  }}>
                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                      <Rating 
                        value={hotelData.rating} 
                        precision={0.5} 
                        readOnly 
                        sx={{
                          '& .MuiRating-iconFilled': {
                            color: 'white'
                          },
                          '& .MuiRating-iconEmpty': {
                            color: 'rgba(255, 255, 255, 0.2)'
                          }
                        }}
                      />
                      <Typography variant="body2" sx={{ ml: 1, color: 'rgba(255, 255, 255, 0.7)' }}>
                        {hotelData.rating} ({hotelData.reviews} reviews)
                      </Typography>
                    </Box>
                    <Typography variant="body2" sx={{ 
                      color: 'rgba(255, 255, 255, 0.7)',
                      display: 'flex',
                      alignItems: 'center'
                    }}>
                      <LocationOnIcon sx={{ fontSize: 16, mr: 0.5 }} />
                      {hotelData.location}
                    </Typography>
                  </Box>
                </MotionBox>

                <Divider sx={{ my: 4, borderColor: 'rgba(255, 255, 255, 0.03)' }} />

                <MotionBox {...fadeInUp}>
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 4 }}>
                    <Avatar 
                      src={hotelData.host.avatar} 
                      sx={{ 
                        width: 48, 
                        height: 48, 
                        mr: 2,
                        border: '1px solid rgba(255, 255, 255, 0.05)'
                      }}
                    />
                    <Box>
                      <Typography variant="subtitle1" sx={{ fontWeight: 400 }}>
                        Hosted by {hotelData.host.name}
                      </Typography>
                      <Typography variant="body2" sx={{ 
                        color: 'rgba(255, 255, 255, 0.5)',
                        mt: 0.5,
                        fontSize: '0.875rem'
                      }}>
                        Joined {hotelData.host.joined} • {hotelData.host.responseRate} response rate
                      </Typography>
                    </Box>
                  </Box>
                </MotionBox>

                <Divider sx={{ my: 4, borderColor: 'rgba(255, 255, 255, 0.03)' }} />

                <MotionBox {...fadeInUp}>
                  <Typography variant="subtitle1" sx={{ mb: 2, fontWeight: 400 }}>
                    About
                  </Typography>
                  <Typography variant="body2" sx={{ 
                    lineHeight: 1.7,
                    color: 'rgba(255, 255, 255, 0.7)'
                  }}>
                    {hotelData.description}
                  </Typography>
                </MotionBox>

                <Divider sx={{ my: 4, borderColor: 'rgba(255, 255, 255, 0.03)' }} />

                <MotionBox {...fadeInUp}>
                  <Typography variant="subtitle1" sx={{ mb: 3, fontWeight: 400 }}>
                    Amenities
                  </Typography>
                  <Grid container spacing={1}>
                    {hotelData.features.map((feature, index) => (
                      <Grid item xs={12} sm={6} key={index}>
                        <MotionBox
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ duration: 0.2, delay: index * 0.05 }}
                          sx={{ 
                            display: 'flex', 
                            alignItems: 'center',
                            py: 1,
                            px: 1,
                          }}
                        >
                          <Box sx={{ mr: 2, color: 'rgba(255, 255, 255, 0.5)' }}>
                            {getFeatureIcon(feature)}
                          </Box>
                          <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.7)' }}>
                            {feature}
                          </Typography>
                        </MotionBox>
                      </Grid>
                    ))}
                  </Grid>
                </MotionBox>
              </MotionBox>
            </Grid>

            <Grid item xs={12} md={4}>
              <MotionCard
                {...fadeInUp}
                elevation={0}
                sx={{ 
                  bgcolor: 'rgba(255, 255, 255, 0.02)',
                  border: '1px solid rgba(255, 255, 255, 0.03)',
                  borderRadius: 2,
                  position: 'sticky',
                  top: 20,
                }}
              >
                <CardContent sx={{ p: 3 }}>
                  <Box sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between', 
                    alignItems: 'baseline', 
                    mb: 3 
                  }}>
                    <Typography variant="h5" component="div" sx={{ fontWeight: 400 }}>
                      ₹{hotelData.price}
                    </Typography>
                    <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.5)' }}>
                      per night
                    </Typography>
                  </Box>

                  <Button 
                    variant="outlined" 
                    fullWidth 
                    sx={{ 
                      borderColor: 'rgba(255, 255, 255, 0.1)',
                      color: 'white',
                      py: 1,
                      textTransform: 'none',
                      fontSize: '0.95rem',
                      fontWeight: 400,
                      '&:hover': {
                        borderColor: 'rgba(255, 255, 255, 0.2)',
                        background: 'rgba(255, 255, 255, 0.02)',
                      }
                    }}
                  >
                    Reserve
                  </Button>
                  
                  <Typography 
                    variant="caption" 
                    sx={{ 
                      display: 'block',
                      textAlign: 'center', 
                      mt: 2, 
                      color: 'rgba(255, 255, 255, 0.5)'
                    }}
                  >
                    You won't be charged yet
                  </Typography>
                </CardContent>
              </MotionCard>
            </Grid>
          </Grid>

          <Dialog 
            open={open} 
            onClose={handleClose} 
            maxWidth="sm" 
            fullWidth
            PaperProps={{
              elevation: 0,
              sx: {
                bgcolor: 'rgba(18, 18, 18, 0.98)',
                backdropFilter: 'blur(20px)',
                color: 'white',
                borderRadius: 2,
                border: '1px solid rgba(255, 255, 255, 0.05)'
              }
            }}
          >
            <DialogTitle sx={{ 
              borderBottom: '1px solid rgba(255, 255, 255, 0.03)',
              py: 2
            }}>
              Edit Profile
            </DialogTitle>
            <DialogContent sx={{ mt: 2 }}>
              <TextField
                fullWidth
                label="Description"
                multiline
                rows={4}
                value={editData.description}
                onChange={(e) => setEditData({ ...editData, description: e.target.value })}
                sx={{ 
                  '& .MuiOutlinedInput-root': { 
                    color: 'white',
                    '& fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.05)'
                    },
                    '&:hover fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.1)'
                    },
                    '&.Mui-focused fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.2)'
                    }
                  },
                  '& .MuiInputLabel-root': {
                    color: 'rgba(255, 255, 255, 0.5)'
                  }
                }}
              />
              <TextField
                fullWidth
                label="Features (comma-separated)"
                value={editData.features.join(', ')}
                onChange={handleFeatureChange}
                sx={{ 
                  mt: 3,
                  '& .MuiOutlinedInput-root': { 
                    color: 'white',
                    '& fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.05)'
                    },
                    '&:hover fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.1)'
                    },
                    '&.Mui-focused fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.2)'
                    }
                  },
                  '& .MuiInputLabel-root': {
                    color: 'rgba(255, 255, 255, 0.5)'
                  }
                }}
              />
              <TextField
                fullWidth
                label="Location"
                value={editData.location}
                onChange={(e) => setEditData({ ...editData, location: e.target.value })}
                sx={{ 
                  mt: 3,
                  '& .MuiOutlinedInput-root': { 
                    color: 'white',
                    '& fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.05)'
                    },
                    '&:hover fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.1)'
                    },
                    '&.Mui-focused fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.2)'
                    }
                  },
                  '& .MuiInputLabel-root': {
                    color: 'rgba(255, 255, 255, 0.5)'
                  }
                }}
              />
              <TextField
                fullWidth
                label="Price per night"
                type="number"
                value={editData.price}
                onChange={(e) => setEditData({ ...editData, price: parseInt(e.target.value) })}
                sx={{ 
                  mt: 3,
                  '& .MuiOutlinedInput-root': { 
                    color: 'white',
                    '& fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.05)'
                    },
                    '&:hover fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.1)'
                    },
                    '&.Mui-focused fieldset': {
                      borderColor: 'rgba(255, 255, 255, 0.2)'
                    }
                  },
                  '& .MuiInputLabel-root': {
                    color: 'rgba(255, 255, 255, 0.5)'
                  }
                }}
              />
            </DialogContent>
            <DialogActions sx={{ 
              p: 2, 
              borderTop: '1px solid rgba(255, 255, 255, 0.03)'
            }}>
              <Button 
                onClick={handleClose} 
                sx={{ 
                  color: 'rgba(255, 255, 255, 0.5)',
                  '&:hover': {
                    color: 'white',
                    background: 'rgba(255, 255, 255, 0.02)'
                  }
                }}
              >
                Cancel
              </Button>
              <Button 
                onClick={handleSave} 
                variant="outlined" 
                sx={{ 
                  borderColor: 'rgba(255, 255, 255, 0.1)',
                  color: 'white',
                  '&:hover': {
                    borderColor: 'rgba(255, 255, 255, 0.2)',
                    background: 'rgba(255, 255, 255, 0.02)'
                  },
                  px: 3
                }}
              >
                Save
              </Button>
            </DialogActions>
          </Dialog>
        </MotionPaper>
      </MotionBox>
    </AnimatePresence>
  );
};

export default AppView; 