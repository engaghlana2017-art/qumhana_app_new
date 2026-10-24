
const express = require('express');
const bodyParser = require('body-parser');
const sql = require('msnodesqlv8');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

// الاتصال عبر السيرفر المحلي الأساسي (بدون اسم المثيل، أو باستخدام البورت المباشر)
const connectionString = "Server=DESKTOP-R6CO1OA;Database=QumhanaDB;Trusted_Connection=Yes;Driver={SQL Server Native Client 11.0};";

async function startServer() {
    console.log("جاري الاتصال بقاعدة البيانات...");

    sql.open(connectionString, (err, conn) => {
        if (err) {
            console.error("فشل الاتصال بقاعدة البيانات:", err);
            return;
        }

        console.log("Connected to SQL Server successfully!");

        // 1. مسار إرسال طلب جديد من المواطن
        app.post('/requests', (req, res) => {
            const { title, desc } = req.body;
            const query = "INSERT INTO Requests (title, [desc]) VALUES (?, ?)";
            
            conn.query(query, [title, desc], (dbErr, result) => {
                if (dbErr) {
                    console.error('Error inserting request:', dbErr);
                    return res.status(500).json({ error: dbErr.message });
                }
                res.status(201).json({ message: 'Request created successfully' });
            });
        });

        // 2. مسار جلب كافة الطلبات للموظف
        app.get('/requests', (req, res) => {
            const query = "SELECT * FROM Requests ORDER BY id DESC";
            
            conn.query(query, (dbErr, rows) => {
                if (dbErr) {
                    console.error('Error fetching requests:', dbErr);
                    return res.status(500).json({ error: dbErr.message });
                }
                res.json(rows);
            });
        });

        const PORT = 3000;
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    });
}

startServer();