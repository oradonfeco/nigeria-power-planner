# nigeria-power-planner (Load Shedding Copilot)

This Clarity smart contract solution is to help Nigerians plan their electricity usage during power outages, optimize generator/solar usage, and track NEPA/PREPAY meter statistics.

## Overview

Nigeria Power Planner is a blockchain-based solution that addresses the daily challenges of power outages in Nigeria. The application helps users:

- Track and report power outages in their location
- Record and analyze electricity usage patterns
- Optimize generator and solar power usage
- Calculate cost savings from efficient power management
- Share and verify outage information with the community

## Smart Contract Features

The Clarity smart contract provides the following functionality:

1. **User Profile Management**
   - Register new users with their electricity usage preferences
   - Update user profiles with current information
   - Store meter types (NEPA/PREPAY) and numbers

2. **Power Outage Tracking**
   - Report power outages with location, date, and duration
   - Confirm outages reported by other users
   - Calculate average outage durations by location

3. **Electricity Usage Recording**
   - Track grid, generator, and solar electricity usage
   - Record costs associated with different power sources
   - Monitor hours without power

4. **Optimization Recommendations**
   - Generate personalized recommendations for generator runtime
   - Calculate optimal solar usage based on capacity
   - Estimate cost savings from following recommendations

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Stacks Wallet](https://www.hiro.so/wallet) - For interacting with the deployed contract

### Installation

1. Clone the repository:

2. Install dependencies:

clarinet install
Test the contract:

clarinet test
Deployment
Deploy to the Stacks testnet:

clarinet deploy --testnet
Deploy to the Stacks mainnet (when ready):

clarinet deploy --mainnet
Usage Examples
Register a New User
(contract-call? .electricity-planner register-user 
  "John Doe" 
  "Lagos, Ikeja" 
  "PREPAY" 
  "12345678901" 
  u15 
  true 
  u5 
  false 
  u0)
Report a Power Outage
(contract-call? .electricity-planner report-power-outage 
  "Lagos, Ikeja" 
  u20230615 
  u1400 
  u1800)
Record Electricity Usage
(contract-call? .electricity-planner record-electricity-usage 
  u20230615 
  u5 
  u10 
  u0 
  u2000 
  u5000 
  u8)
Generate Recommendations
(contract-call? .electricity-planner generate-recommendations)
Future Enhancements
Integration with IoT devices for automated outage reporting
Mobile app for easy access and notifications
Community-based outage prediction algorithm
Integration with payment systems for prepaid meter top-ups
Marketplace for generator fuel and solar equipment
Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Thanks to the Nigerian community for inspiring this solution
Special thanks to the Stacks ecosystem for providing the blockchain infrastructure
