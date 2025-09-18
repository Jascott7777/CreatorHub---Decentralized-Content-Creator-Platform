# CreatorHub - Decentralized Content Creator Platform

A blockchain-based platform for content creation, fan engagement, and monetization with community-driven rewards built on the Stacks blockchain using Clarity smart contracts.

[![Built with Stacks](https://img.shields.io/badge/Built_with-Stacks-purple.svg)](https://www.stacks.co/)
[![Smart Contract](https://img.shields.io/badge/Smart_Contract-Clarity-orange.svg)](https://clarity-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Overview

CreatorHub revolutionizes content creation by providing a decentralized platform where creators can monetize their work, engage with communities, collaborate on projects, and build sustainable creative careers. Through blockchain technology and tokenized incentives, creators earn rewards for quality content, community engagement, and collaborative contributions.

## Key Features

### Content Creation & Monetization
- **Multi-format Content Support**: Digital art, music, writing, video, code projects, and photography
- **Tokenized Rewards**: Earn CHT tokens for posts, likes, collaborations, and milestones
- **Subscription Tiers**: Create multiple subscription levels with custom benefits and pricing
- **Community Engagement**: Direct fan interaction through likes, shares, and tips

### Collaboration System
- **Project-based Collaborations**: Create and join collaborative projects across different creative disciplines
- **Role-based Participation**: Define specific roles and responsibilities for team members
- **Contribution Scoring**: Track and reward individual contributions to group projects
- **Cross-disciplinary Projects**: Support for music, art, writing, tech, and mixed-media collaborations

### Event Management
- **Creator Events**: Host showcases, workshops, meetups, and product launches
- **Ticketing System**: Built-in event registration and attendance tracking
- **Community Building**: Connect creators and fans through live events
- **Feedback System**: Post-event rating and feedback collection

### Profile & Reputation System
- **Creator Levels**: Progress through 10 levels based on activity and quality
- **Reputation Scoring**: Build credibility through community contributions
- **Achievement Milestones**: Unlock rewards for reaching specific goals
- **Creator Types**: Specialized profiles for artists, writers, musicians, developers, and designers

## Token Economy (CHT - CreatorHub Creator Token)

### Token Details
- **Name**: CreatorHub Creator Token
- **Symbol**: CHT
- **Decimals**: 6
- **Total Supply**: 200,000 CHT
- **Blockchain**: Stacks

### Reward Structure
```
Content Post Creation:    2 CHT
Post Like (to creator):   0.5 CHT
Collaboration Completion: 15 CHT (base + contribution bonus)
Creator Milestone:        25 CHT
Subscription Tier Setup:  8 CHT
```

## Smart Contract Architecture

### Core Data Structures

#### Creator Profile
```clarity
{
  username: string,
  creator-type: string, // "artist", "writer", "musician", "developer", "designer"
  total-posts: uint,
  total-likes: uint,
  followers: uint,
  collaborations: uint,
  creator-level: uint, // 1-10
  reputation-score: uint,
  join-date: uint,
  last-activity: uint
}
```

#### Content Post
```clarity
{
  creator: principal,
  title: string,
  description: string,
  content-type: string,
  content-url: string,
  likes: uint,
  shares: uint,
  post-date: uint,
  monetized: bool,
  verified: bool
}
```

#### Collaboration Project
```clarity
{
  initiator: principal,
  project-title: string,
  project-description: string,
  project-type: string, // "music", "art", "writing", "tech", "mixed"
  max-collaborators: uint,
  current-collaborators: uint,
  duration-days: uint,
  start-date: uint,
  end-date: uint,
  reward-pool: uint,
  active: bool
}
```

### Content Categories

The platform supports multiple content types with different point values and engagement multipliers:

| Category | Type | Base Points | Engagement Multiplier |
|----------|------|-------------|---------------------|
| Digital Art | art | 20 | 2x |
| Music Track | music | 25 | 3x |
| Blog Post | writing | 15 | 2x |
| Video Content | video | 30 | 3x |
| Code Project | code | 22 | 2x |
| Photography | art | 18 | 2x |

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Stacks Wallet](https://www.hiro.so/wallet) - For interacting with the contract
- Basic understanding of Clarity smart contracts

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/creatorhub-platform.git
cd creatorhub-platform
```

2. **Install Clarinet**
```bash
curl -L https://github.com/hirosystems/clarinet/releases/download/v1.8.0/clarinet-linux-x64.tar.gz | tar xz
mv clarinet /usr/local/bin/
```

3. **Initialize project**
```bash
clarinet new creatorhub-project
cd creatorhub-project
# Copy the contract file to contracts/creatorhub.clar
```

### Deployment

1. **Test the contract**
```bash
clarinet test
```

2. **Deploy to devnet**
```bash
clarinet integrate
```

3. **Deploy to testnet/mainnet**
```bash
clarinet deployment apply -p testnet
```

## Usage Examples

### Initialize Content Categories
```clarity
;; Set up the basic content categories
(contract-call? .creatorhub init-content-categories)
```

### Create a Content Post
```clarity
;; Post a digital artwork
(contract-call? .creatorhub create-post
  "Sunset Landscape"
  "A digital painting capturing the golden hour over mountain ranges"
  "digital-art"
  "https://ipfs.io/ipfs/QmYourArtworkHash"
)
```

### Like a Post
```clarity
;; Like another creator's post (rewards both liker and creator)
(contract-call? .creatorhub like-post u1)
```

### Start a Collaboration
```clarity
;; Create a music collaboration project
(contract-call? .creatorhub create-collaboration
  "Electronic Music EP"
  "Looking for producers and vocalists to create a 4-track electronic EP"
  "music"
  u5  ;; max 5 collaborators
  u30 ;; 30 days duration
)
```

### Join a Collaboration
```clarity
;; Join an existing collaboration as a producer
(contract-call? .creatorhub join-collaboration
  u1     ;; collaboration ID
  "producer"
)
```

### Create an Event
```clarity
;; Host a digital art showcase
(contract-call? .creatorhub create-creator-event
  "Digital Art Showcase 2024"
  "showcase"
  "Featuring emerging digital artists and their latest works"
  u100   ;; max 100 attendees
  u5     ;; 5 CHT ticket price
)
```

### Set Up Subscription Tier
```clarity
;; Create a premium subscription tier
(contract-call? .creatorhub create-subscription-tier
  "premium"
  "Get exclusive access to behind-the-scenes content and early releases"
  u10    ;; 10 CHT per month
  "Exclusive content, early access, monthly Q&A sessions, custom requests"
)
```

## Core Functions

### Content Management
- `create-post(title, description, content-type, content-url)` - Publish new content
- `like-post(post-id)` - Engage with creator content
- `get-content-post(post-id)` - Retrieve post details
- `verify-post(post-id)` - Admin verification of content

### Collaboration System
- `create-collaboration(...)` - Start collaborative projects
- `join-collaboration(collab-id, role)` - Participate in projects
- `complete-collaboration(collab-id, contribution-score)` - Finalize contributions
- `get-collaboration-project(collab-id)` - View project details

### Event Management
- `create-creator-event(...)` - Host community events
- `register-for-event(event-id)` - Sign up for events
- `get-creator-event(event-id)` - View event information

### Profile & Monetization
- `update-profile(username, creator-type)` - Update creator information
- `create-subscription-tier(...)` - Set up monetization tiers
- `claim-creator-milestone(milestone)` - Unlock achievement rewards
- `get-creator-profile(creator)` - View creator statistics

### Token Operations
- `get-balance(user)` - Check CHT balance
- `get-total-supply()` - View total token supply
- `get-name()`, `get-symbol()`, `get-decimals()` - Token metadata

## Creator Milestones

Creators can claim milestone rewards by achieving specific goals:

| Milestone | Requirement | Reward |
|-----------|-------------|---------|
| Content Creator 50 | Create 50 posts | 25 CHT |
| Viral Creator 1000 | Receive 1000 likes | 25 CHT |
| Collaboration Master 10 | Complete 10 collaborations | 25 CHT |
| Community Builder 100 | Gain 100 followers | 25 CHT |

## Access Controls & Requirements

### Creator Level Requirements
- **Collaboration Creation**: Level 3+ required
- **Event Hosting**: 150+ reputation score required
- **Subscription Tiers**: Level 5+ required

### Anti-Spam Measures
- Users cannot like their own posts
- Duplicate interactions prevented
- Creator level gates for advanced features
- Reputation score requirements for hosting events

## Security Features

### Input Validation
- String length limits for all text fields
- Valid content category verification
- Collaboration duration limits (1-365 days)
- Contribution score validation (0-100)

### Access Control
- Owner-only administrative functions
- Creator level and reputation requirements
- Self-interaction prevention
- Duplicate action prevention

### Error Handling
```clarity
u100: Owner-only access
u101: Resource not found
u102: Already exists
u103: Unauthorized action
u104: Invalid input
u105: Insufficient tokens
```

## Platform Governance

### Content Moderation
- Admin verification system for posts
- Community-driven quality control through likes and engagement
- Creator level requirements for advanced features

### Token Economics
- Fixed supply with no inflation
- Merit-based token distribution
- Multiple earning mechanisms to prevent token concentration
- Collaboration-based rewards encourage community building

## Development Roadmap

### Phase 1: Core Platform
- Smart contract deployment
- Basic content creation and interaction
- Profile and reputation system
- Token reward mechanics

### Phase 2: Advanced Features
- Enhanced collaboration tools
- Event management system
- Subscription monetization
- Mobile app integration

### Phase 3: Ecosystem Growth
- Cross-platform content sharing
- Advanced analytics dashboard
- Creator funding mechanisms
- Governance token implementation

### Phase 4: Scalability
- Layer 2 integration
- Cross-chain compatibility
- Enterprise creator tools
- AI-powered content recommendations

## Testing

```bash
# Run all tests
clarinet test

# Test specific functionality
clarinet test tests/content_creation_test.ts
clarinet test tests/collaboration_test.ts
clarinet test tests/token_rewards_test.ts

# Validate contract syntax
clarinet check
```

## API Reference

### Read-Only Functions
- `get-creator-profile(creator)` - Retrieve creator information
- `get-content-category(content-type)` - View category details
- `get-content-post(post-id)` - Access post data
- `get-collaboration-project(collab-id)` - View collaboration details
- `get-creator-event(event-id)` - Access event information
- `get-subscription-tier(creator, tier-name)` - View subscription details

### Write Functions
- Content creation and interaction functions
- Collaboration management functions
- Event hosting and registration functions
- Profile and monetization functions
- Administrative functions

## Contributing

We welcome contributions from creators, developers, and community members!

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Implement your changes with tests
4. Submit a pull request
5. Participate in code review

### Contribution Areas
- Smart contract improvements
- User interface development
- Documentation updates
- Testing and quality assurance
- Community feedback and suggestions

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support & Community

- **Documentation**: [docs.creatorhub.io](https://docs.creatorhub.io)
- **Discord**: [Join our community](https://discord.gg/creatorhub)
- **Twitter**: [@CreatorHubPlatform](https://twitter.com/creatorhubplatform)
- **Email**: support@creatorhub.io

## Acknowledgments

- Built on Stacks blockchain infrastructure
- Powered by Clarity smart contracts
- Inspired by the global creator economy
- Community-driven development approach

---

**Empowering creators through decentralized technology**
