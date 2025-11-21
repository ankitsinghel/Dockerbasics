# Use a specific, lightweight base image
FROM node:20.17.0-alpine3.19

# Set working directory 
WORKDIR /home/app

# Copy only package files first (best for caching) 
COPY package*.json ./

# Install dependencies (placed in this layer as it revokes only when package.* files changes as previously it was revoking even on any code changes on any file as it was placed below the copy . . layer)
RUN npm install  

# Copy rest of the project
COPY . .

# Expose port
EXPOSE 1200

# Start the app
CMD ["node", "index.js"]
