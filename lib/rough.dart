// // Get User Orders endpoint
// app.get('/orders/:userId', (req, res) => {
// const userId = req.params.userId;
//
// // SQL query to get orders with cancellation request info
// const sql = `
// SELECT o.order_id, o.order_date, o.total_amount, o.status,
// o.shipping_address, o.payment_method,
// cr.request_id, cr.status as cancellation_status
// FROM orders o
// LEFT JOIN cancellation_requests cr ON o.order_id = cr.order_id
// AND cr.status IN ('pending', 'approved', 'rejected')
// WHERE o.user_id = ?
// ORDER BY o.order_date DESC
// `;
//
// db.query(sql, [userId], (err, results) => {
// if (err) {
// console.error("Order fetch error:", err);
// return res.status(500).json({ error: "Failed to fetch orders" });
// }
//
// // Process the results to handle cancellation requests
// const processedResults = results.map(order => ({
// order_id: order.order_id,
// order_date: new Date(order.order_date).toLocaleString(),
// total_amount: order.total_amount,
// status: order.status,
// shipping_address: order.shipping_address,
// payment_method: order.payment_method,
// has_cancellation_request: order.request_id ? true : false,
// cancellation_status: order.cancellation_status || null
// }));
//
// res.json(processedResults);
// });
// });