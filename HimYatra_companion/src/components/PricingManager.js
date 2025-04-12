import React, { useState } from 'react';
import {
  Box,
  Typography,
  Slider,
  Switch,
  FormControlLabel,
  TextField,
  Grid,
  Card,
  CardContent,
  InputAdornment,
  Tooltip,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
} from '@mui/material';
import { motion, AnimatePresence } from 'framer-motion';
import AddIcon from '@mui/icons-material/Add';

const MotionBox = motion(Box);
const MotionCard = motion(Card);
const MotionTypography = motion(Typography);
const MotionChip = motion(Chip);

const cardVariants = {
  hidden: { opacity: 0, y: 20, scale: 0.98 },
  visible: { 
    opacity: 1, 
    y: 0,
    scale: 1,
    transition: {
      duration: 0.8,
      ease: [0.22, 1, 0.36, 1]
    }
  },
  hover: {
    y: -5,
    transition: {
      duration: 0.3,
      ease: [0.22, 1, 0.36, 1]
    }
  }
};

const chipVariants = {
  hidden: { opacity: 0, x: -20, scale: 0.9 },
  visible: (i) => ({
    opacity: 1,
    x: 0,
    scale: 1,
    transition: {
      delay: i * 0.05,
      duration: 0.5,
      ease: [0.22, 1, 0.36, 1]
    }
  }),
  hover: {
    scale: 1.05,
    transition: {
      duration: 0.2,
      ease: [0.22, 1, 0.36, 1]
    }
  }
};

const priceVariants = {
  initial: { scale: 1, opacity: 1 },
  animate: { 
    scale: [1, 1.05, 1],
    opacity: [1, 0.8, 1],
    transition: {
      duration: 0.5,
      ease: [0.22, 1, 0.36, 1]
    }
  }
};

const fadeIn = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      duration: 0.6,
      ease: [0.22, 1, 0.36, 1]
    }
  }
};

function PricingManager() {
  const [basePrice, setBasePrice] = useState(1000);
  const [occupancyRate, setOccupancyRate] = useState(50);
  const [specialEvent, setSpecialEvent] = useState(false);
  const [eventMultiplier, setEventMultiplier] = useState(1.5);
  const [dynamicPricing, setDynamicPricing] = useState(true);
  const [priceAnimation, setPriceAnimation] = useState(false);
  const [roomTypes, setRoomTypes] = useState([
    { name: 'Single', basePrice: 1000 },
    { name: 'Deluxe', basePrice: 2000 },
    { name: 'Suite', basePrice: 3000 },
    { name: 'Premium Suite', basePrice: 5000 }
  ]);
  const [selectedRoomType, setSelectedRoomType] = useState('Single');
  const [openDialog, setOpenDialog] = useState(false);
  const [newRoomName, setNewRoomName] = useState('');
  const [newRoomPrice, setNewRoomPrice] = useState('');

  const handleBasePriceChange = (event) => {
    const value = Math.max(0, Number(event.target.value));
    setBasePrice(value);
    setPriceAnimation(true);
    setTimeout(() => setPriceAnimation(false), 400);
  };

  const handleEventMultiplierChange = (event) => {
    const value = Math.min(3, Math.max(1, Number(event.target.value)));
    setEventMultiplier(Number(value.toFixed(2)));
    setPriceAnimation(true);
    setTimeout(() => setPriceAnimation(false), 400);
  };

  const handleOccupancyChange = (event, newValue) => {
    setOccupancyRate(newValue);
    setPriceAnimation(true);
    setTimeout(() => setPriceAnimation(false), 400);
  };

  const handleSpecialEventToggle = () => {
    setSpecialEvent(!specialEvent);
    setPriceAnimation(true);
    setTimeout(() => setPriceAnimation(false), 400);
  };

  const handleDynamicPricingToggle = () => {
    setDynamicPricing(!dynamicPricing);
    setPriceAnimation(true);
    setTimeout(() => setPriceAnimation(false), 400);
  };

  const handleRoomTypeSelect = (roomType) => {
    setSelectedRoomType(roomType.name);
    setBasePrice(roomType.basePrice);
    setPriceAnimation(true);
    setTimeout(() => setPriceAnimation(false), 400);
  };

  const handleAddRoomType = () => {
    if (newRoomName && newRoomPrice && Number(newRoomPrice) > 0) {
      setRoomTypes([...roomTypes, { 
        name: newRoomName, 
        basePrice: Number(newRoomPrice) 
      }]);
      setNewRoomName('');
      setNewRoomPrice('');
      setOpenDialog(false);
    }
  };

  const calculateFinalPrice = () => {
    let finalPrice = basePrice;
    
    if (dynamicPricing) {
      // Apply occupancy-based pricing
      const occupancyMultiplier = 1 + (occupancyRate / 100);
      finalPrice *= occupancyMultiplier;

      // Apply special event pricing if enabled
      if (specialEvent) {
        const occupancyInfluence = occupancyRate / 100;
        const maxMultiplier = 3;
        const effectiveMultiplier = 1 + (eventMultiplier - 1) * (1 + occupancyInfluence);
        finalPrice *= Math.min(effectiveMultiplier, maxMultiplier);
      }
    }

    return Math.round(finalPrice);
  };

  const getPriceExplanation = () => {
    if (!dynamicPricing) return 'Base price (Dynamic pricing disabled)';
    
    let explanation = `Base price: ₹${basePrice}`;
    
    if (occupancyRate > 0) {
      const occupancyMultiplier = 1 + (occupancyRate / 100);
      explanation += ` × ${occupancyMultiplier.toFixed(2)} (Occupancy: ${occupancyRate}%)`;
    }
    
    if (specialEvent) {
      const occupancyInfluence = occupancyRate / 100;
      const effectiveMultiplier = 1 + (eventMultiplier - 1) * (1 + occupancyInfluence);
      explanation += ` × ${Math.min(effectiveMultiplier, 3).toFixed(2)} (Special Event)`;
    }
    
    return explanation;
  };

  return (
    <MotionBox
      initial="hidden"
      animate="visible"
      variants={fadeIn}
      sx={{ 
        maxWidth: '1200px', 
        mx: 'auto'
      }}
    >
      <MotionTypography 
        variant="h4" 
        gutterBottom 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
        sx={{ 
          color: 'white', 
          mb: 4,
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
        Dynamic Pricing Manager
      </MotionTypography>

      <Box sx={{ mb: 4, display: 'flex', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
        <MotionBox
          variants={chipVariants}
          custom={0}
          sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}
        >
          {roomTypes.map((roomType, index) => (
            <MotionChip
              key={roomType.name}
              label={roomType.name}
              onClick={() => handleRoomTypeSelect(roomType)}
              variant={selectedRoomType === roomType.name ? 'filled' : 'outlined'}
              whileHover="hover"
              sx={{
                color: selectedRoomType === roomType.name ? 'white' : 'rgba(255, 255, 255, 0.7)',
                borderColor: 'rgba(255, 255, 255, 0.2)',
                backgroundColor: selectedRoomType === roomType.name ? 'rgba(255, 255, 255, 0.1)' : 'transparent',
                '&:hover': {
                  backgroundColor: 'rgba(255, 255, 255, 0.15)',
                },
                transition: 'all 0.3s ease',
              }}
              variants={chipVariants}
              custom={index + 1}
            />
          ))}
        </MotionBox>
        <Tooltip title="Add new room type">
          <IconButton
            onClick={() => setOpenDialog(true)}
            sx={{
              color: 'rgba(255, 255, 255, 0.7)',
              '&:hover': {
                color: 'white',
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
              },
              transition: 'all 0.3s ease',
            }}
          >
            <AddIcon />
          </IconButton>
        </Tooltip>
      </Box>

      <Grid container spacing={4}>
        <Grid item xs={12} md={6}>
          <MotionCard
            variants={cardVariants}
            whileHover="hover"
            sx={{
              background: 'rgba(255, 255, 255, 0.03)',
              backdropFilter: 'blur(20px)',
              border: '1px solid rgba(255, 255, 255, 0.05)',
              borderRadius: '20px',
              transition: 'all 0.3s ease',
              boxShadow: '0 4px 24px rgba(0, 0, 0, 0.1)',
            }}
          >
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, color: 'white', fontFamily: 'Lato' }}>
                Base Price Settings
              </Typography>
              <TextField
                fullWidth
                label="Base Price (₹)"
                type="number"
                value={basePrice}
                onChange={handleBasePriceChange}
                InputProps={{ inputProps: { min: 0 } }}
                sx={{
                  mb: 3,
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
              <FormControlLabel
                control={
                  <Switch
                    checked={dynamicPricing}
                    onChange={handleDynamicPricingToggle}
                    sx={{
                      '& .MuiSwitch-track': {
                        backgroundColor: 'rgba(255, 255, 255, 0.2)',
                      },
                      '& .MuiSwitch-thumb': {
                        backgroundColor: 'white',
                      },
                    }}
                  />
                }
                label="Enable Dynamic Pricing"
                sx={{ color: 'white', fontFamily: 'Lato' }}
              />
            </CardContent>
          </MotionCard>
        </Grid>

        <Grid item xs={12} md={6}>
          <MotionCard
            variants={cardVariants}
            whileHover="hover"
            sx={{
              background: 'rgba(255, 255, 255, 0.03)',
              backdropFilter: 'blur(20px)',
              border: '1px solid rgba(255, 255, 255, 0.05)',
              borderRadius: '20px',
              transition: 'all 0.3s ease',
              boxShadow: '0 4px 24px rgba(0, 0, 0, 0.1)',
            }}
          >
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, color: 'white', fontFamily: 'Lato' }}>
                Occupancy Settings
              </Typography>
              <Typography sx={{ mb: 2, color: 'rgba(255, 255, 255, 0.7)', fontFamily: 'Lato' }}>
                Current Occupancy Rate: {occupancyRate}%
              </Typography>
              <Slider
                value={occupancyRate}
                onChange={handleOccupancyChange}
                min={0}
                max={100}
                disabled={!dynamicPricing}
                sx={{
                  color: 'white',
                  '& .MuiSlider-track': {
                    background: 'linear-gradient(to right, rgba(255, 255, 255, 0.3), white)',
                  },
                  '& .MuiSlider-thumb': {
                    backgroundColor: 'white',
                    '&:hover': {
                      boxShadow: '0 0 0 8px rgba(255, 255, 255, 0.16)',
                    },
                  },
                }}
              />
            </CardContent>
          </MotionCard>
        </Grid>

        <Grid item xs={12} md={6}>
          <MotionCard
            variants={cardVariants}
            whileHover="hover"
            sx={{
              background: 'rgba(255, 255, 255, 0.03)',
              backdropFilter: 'blur(20px)',
              border: '1px solid rgba(255, 255, 255, 0.05)',
              borderRadius: '20px',
              transition: 'all 0.3s ease',
              boxShadow: '0 4px 24px rgba(0, 0, 0, 0.1)',
            }}
          >
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, color: 'white', fontFamily: 'Lato' }}>
                Special Event Pricing
              </Typography>
              <FormControlLabel
                control={
                  <Switch
                    checked={specialEvent}
                    onChange={handleSpecialEventToggle}
                    disabled={!dynamicPricing}
                    sx={{
                      '& .MuiSwitch-track': {
                        backgroundColor: 'rgba(255, 255, 255, 0.2)',
                      },
                      '& .MuiSwitch-thumb': {
                        backgroundColor: 'white',
                      },
                    }}
                  />
                }
                label="Enable Special Event Pricing"
                sx={{ color: 'white', fontFamily: 'Lato' }}
              />
              <AnimatePresence>
                {specialEvent && (
                  <motion.div
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: 'auto' }}
                    exit={{ opacity: 0, height: 0 }}
                    transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
                  >
                    <TextField
                      fullWidth
                      label="Event Price Multiplier"
                      type="number"
                      value={eventMultiplier}
                      onChange={handleEventMultiplierChange}
                      InputProps={{ 
                        inputProps: { 
                          min: 1, 
                          max: 3, 
                          step: 0.01 
                        } 
                      }}
                      sx={{
                        mt: 2,
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
                  </motion.div>
                )}
              </AnimatePresence>
            </CardContent>
          </MotionCard>
        </Grid>

        <Grid item xs={12} md={6}>
          <MotionCard
            variants={cardVariants}
            whileHover="hover"
            sx={{
              background: 'rgba(255, 255, 255, 0.03)',
              backdropFilter: 'blur(20px)',
              border: '1px solid rgba(255, 255, 255, 0.05)',
              borderRadius: '20px',
              transition: 'all 0.3s ease',
              boxShadow: '0 4px 24px rgba(0, 0, 0, 0.1)',
            }}
          >
            <CardContent>
              <Typography variant="h6" sx={{ mb: 3, color: 'white', fontFamily: 'Lato' }}>
                Final Price
              </Typography>
              <Tooltip title={getPriceExplanation()} placement="top">
                <MotionTypography
                  variant="h4"
                  animate={priceAnimation ? 'animate' : 'initial'}
                  variants={priceVariants}
                  sx={{
                    color: 'white',
                    fontFamily: 'Lato',
                    fontWeight: 700,
                    textAlign: 'center',
                    mb: 2,
                  }}
                >
                  ₹{calculateFinalPrice()}
                </MotionTypography>
              </Tooltip>
              <Typography
                variant="body2"
                sx={{
                  color: 'rgba(255, 255, 255, 0.6)',
                  fontFamily: 'Lato',
                  textAlign: 'center',
                  fontStyle: 'italic',
                }}
              >
                {getPriceExplanation()}
              </Typography>
            </CardContent>
          </MotionCard>
        </Grid>
      </Grid>

      <Dialog
        open={openDialog}
        onClose={() => setOpenDialog(false)}
        PaperProps={{
          sx: {
            background: 'rgba(255, 255, 255, 0.03)',
            backdropFilter: 'blur(20px)',
            border: '1px solid rgba(255, 255, 255, 0.05)',
            borderRadius: '20px',
            color: 'white',
          }
        }}
      >
        <DialogTitle sx={{ fontFamily: 'Lato' }}>Add New Room Type</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Room Name"
            fullWidth
            value={newRoomName}
            onChange={(e) => setNewRoomName(e.target.value)}
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
            label="Base Price (₹)"
            type="number"
            fullWidth
            value={newRoomPrice}
            onChange={(e) => setNewRoomPrice(e.target.value)}
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
            disabled={!newRoomName || !newRoomPrice || Number(newRoomPrice) <= 0}
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

export default PricingManager; 