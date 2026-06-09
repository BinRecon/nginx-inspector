/* ===========================================
   CHART INITIALIZATION & CONFIGURATION
   =========================================== */

let requestsChart = null;
let statusChart = null;

document.addEventListener('DOMContentLoaded', () => {
    initializeCharts();
});

function initializeCharts() {
    // Chart colors
    const chartColors = {
        primary: '#667eea',
        secondary: '#764ba2',
        success: '#48bb78',
        warning: '#f6ad55',
        danger: '#f56565',
        info: '#4299e1'
    };

    // Requests Over Time Chart
    const requestsCtx = document.getElementById('requestsChart');
    if (requestsCtx) {
        requestsChart = new Chart(requestsCtx, {
            type: 'line',
            data: {
                labels: ['12:00 AM', '2:00 AM', '4:00 AM', '6:00 AM', '8:00 AM', '10:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '6:00 PM', '8:00 PM', '10:00 PM'],
                datasets: [
                    {
                        label: 'Successful Requests (2xx)',
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                        borderColor: chartColors.success,
                        backgroundColor: 'rgba(72, 187, 120, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 4,
                        pointBackgroundColor: chartColors.success,
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2
                    },
                    {
                        label: 'Client Errors (4xx)',
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                        borderColor: chartColors.warning,
                        backgroundColor: 'rgba(246, 173, 85, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 4,
                        pointBackgroundColor: chartColors.warning,
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2
                    },
                    {
                        label: 'Server Errors (5xx)',
                        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                        borderColor: chartColors.danger,
                        backgroundColor: 'rgba(245, 101, 101, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 4,
                        pointBackgroundColor: chartColors.danger,
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: {
                            usePointStyle: true,
                            padding: 15,
                            font: {
                                size: 12,
                                weight: '600'
                            }
                        }
                    },
                    filler: {
                        propagate: true
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            drawBorder: false,
                            color: 'rgba(0, 0, 0, 0.05)'
                        },
                        ticks: {
                            font: {
                                size: 12
                            }
                        }
                    },
                    x: {
                        grid: {
                            display: false,
                            drawBorder: false
                        },
                        ticks: {
                            font: {
                                size: 12
                            }
                        }
                    }
                }
            }
        });
    }

    // HTTP Status Codes Chart
    const statusCtx = document.getElementById('statusChart');
    if (statusCtx) {
        statusChart = new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: ['200 OK', '301 Redirect', '404 Not Found', '403 Forbidden', '500 Server Error', '503 Unavailable'],
                datasets: [
                    {
                        data: [0, 0, 0, 0, 0, 0],
                        backgroundColor: [
                            chartColors.success,
                            chartColors.info,
                            chartColors.warning,
                            '#f9a825',
                            chartColors.danger,
                            '#e53e3e'
                        ],
                        borderColor: '#fff',
                        borderWidth: 3
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            usePointStyle: true,
                            padding: 15,
                            font: {
                                size: 12,
                                weight: '600'
                            }
                        }
                    }
                }
            }
        });
    }
}

// Update chart data
function updateChartsWithData(stats) {
    if (!stats || !stats.statusCodes) return;
    
    // Update status chart
    if (statusChart && stats.statusCodes) {
        const codes = Object.keys(stats.statusCodes);
        const counts = Object.values(stats.statusCodes);
        
        statusChart.data.labels = codes;
        statusChart.data.datasets[0].data = counts;
        statusChart.update();
    }
}

// Time range filter
const timeRangeSelect = document.getElementById('timeRange');
if (timeRangeSelect) {
    timeRangeSelect.addEventListener('change', (e) => {
        console.log('Time range changed to:', e.target.value);
        // This would trigger data reload from API with new time range
    });
}
