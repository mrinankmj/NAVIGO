const mongoose = require('mongoose');

const pointSchema = new mongoose.Schema({
  label: String,
  x: Number,
  y: Number,
  z: Number
});

const mapSchema = new mongoose.Schema({
  name: String,
  calibrationPoint: pointSchema,
  pointsOfInterest: [pointSchema],
  paths: [[String]], // Stores connections between POIs
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Map', mapSchema);
