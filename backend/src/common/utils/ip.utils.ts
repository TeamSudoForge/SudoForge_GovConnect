export function getClientIp(req: any): string {
  // Try to get the real IP address from various headers
  const forwarded = req.headers['x-forwarded-for'];
  const realIp = req.headers['x-real-ip'];
  const cfConnectingIp = req.headers['cf-connecting-ip'];
  const socketIp = req.connection?.remoteAddress || req.socket?.remoteAddress;
  
  if (forwarded) {
    const ips = forwarded.split(',').map((ip: string) => ip.trim());
    return ips[0]; // First IP is the original client
  }
  
  // Use other headers or socket IP
  return realIp || cfConnectingIp || socketIp || req.ip || 'unknown';
}
