#!/bin/bash
# Clean .env file - remove SSH vars and update for Claudable

sed -i '' '/SSH_/d' .env
sed -i '' '/DOCKER_HOST/d' .env

# Add FREEAI key placeholder if missing
grep -q "FREEAI_API_KEY" .env || echo "FREEAI_API_KEY=your_freeai_key_here" >> .env

echo "✅ .env cleaned"