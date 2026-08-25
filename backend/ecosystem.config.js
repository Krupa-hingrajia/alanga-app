/**
 * PM2 Ecosystem Configuration — ALANGA Marketplace Backend
 *
 * Usage:
 *   pm2 start ecosystem.config.js          # Start production server
 *   pm2 stop alanga-backend               # Stop
 *   pm2 restart alanga-backend            # Restart
 *   pm2 logs alanga-backend               # View logs
 *   pm2 monit                              # Live monitor
 *   pm2 save && pm2 startup               # Auto-start on server reboot
 */

module.exports = {
  apps: [
    {
      name: 'alanga-backend',
      script: 'dist/main.js',

      // Cluster mode — use all available CPU cores for better throughput
      instances: 'max',
      exec_mode: 'cluster',

      // Environment
      env: {
        NODE_ENV: 'development',
        PORT: 3000,
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
      },

      // Auto-restart on crash
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',

      // Logging
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      merge_logs: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',

      // Graceful shutdown timeout (ms)
      kill_timeout: 5000,
    },
  ],
};
