using System.Diagnostics;

namespace TorServer.Services
{
    public class TorServer : BackgroundService
    {
        private readonly ILogger<TorServer> _logger;

        public TorServer(ILogger<TorServer> logger) => _logger = logger;

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("TorServer is running");
                try
                {
                    var process = new Process();
                    process.StartInfo.FileName = "tor";
                    process.StartInfo.Arguments = "-f /etc/tor/torrc";

                    process.Start();
                    await process.WaitForExitAsync(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError("{error}", ex);
                }
                await Task.Delay(5000, stoppingToken);
            }
        }
    }
}