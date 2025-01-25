var express = require("express");
const fs = require("fs");
var cors = require("cors");
var router = express.Router();
var db = require("./db");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const uploadDir = "uploads/";
const nodemailer = require("nodemailer");
const crypto = require("crypto");
const { OAuth2Client } = require("google-auth-library");

require("dotenv").config();
router.use(cors());

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}_${file.originalname}`);
  },
});

const upload = multer({
  storage,
});

router.post("/register", async (req, res) => {
  const { user_name, user_email, user_password } = req.body;

  if (!user_name || !user_email || !user_password) {
<<<<<<< HEAD
=======
    console.log(user_name);
>>>>>>> 616f688 (update backend')
    return res.status(400).send("Missing required fields");
  }

  try {
    const query =
      "INSERT INTO user (user_name, user_email, user_password) VALUES (?, ?, ?)";
    const [result] = await (
      await db
    ).query(query, [user_name, user_email, user_password]);
    res
      .status(200)
      .json({ success: true, message: "User registered successfully" });
    return result[0];
  } catch (err) {
    console.error(err);
    res
      .status(500)
      .json({ success: false, message: "Error while registering user" });
  }
});

router.post("/login", async (req, res) => {
  const { user_email, user_password } = req.body;
<<<<<<< HEAD
=======
  console.log(user_email);
>>>>>>> 616f688 (update backend')

  try {
    const query =
      "Select * from user where user_email = ? and user_password = ?";
    const [rows] = await (await db).query(query, [user_email, user_password]);
<<<<<<< HEAD
=======
    console.log(rows);
>>>>>>> 616f688 (update backend')
    if (rows.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }
<<<<<<< HEAD
=======
    console.log("pass");
>>>>>>> 616f688 (update backend')

    const user = rows[0];

    if (!user) {
      return res.status(401).send("Invalid credentials");
    }

    const token = jwt.sign({ user_id: user.user_id }, "secretKey", {
      expiresIn: "1h",
    });
    res.json({ token, user_id: user.user_id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.post("/logout", (req, res) => {
  res.clearCookie("token");

  return res
    .status(200)
    .json({ success: true, message: "Logged out successfully" });
});

router.get("/friends/:user_id", async (req, res) => {
  const user_id = req.params.user_id;

  try {
    const friends = await (
      await db
    ).query(
      `
      SELECT DISTINCT u.user_id, u.user_name, u.user_email, u.user_profile
FROM user u
JOIN friendShips f 
ON u.user_id = f.friend_id OR u.user_id = f.user_id
WHERE (f.user_id = ? OR f.friend_id = ?) 
  AND f.status = 'accepted'
  AND u.user_id != ?;
    `,
      [user_id, user_id, user_id]
    );
    const friendsData = friends.map((friend) => {
      const { user_profile, ...rest } = friend;
      return {
        ...rest,
        user_profile: user_profile ? user_profile.toString("utf-8") : null,
      };
    });

    return res.status(200).json({
      success: true,
      data: friendsData,
    });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "친구 목록을 불러오는 데 실패했습니다." });
  }
});

router.post("/post", async (req, res) => {
  const {
    task_title,
    task_description,
    task_startTime,
    task_endTime,
    task_dateTime,
    user_id,
    friend_name,
    plans,
  } = req.body;

  const [userRows] = await (
    await db
  ).query("SELECT user_id FROM user WHERE user_id = ?", [user_id]);
<<<<<<< HEAD
=======
  console.log(userRows);
>>>>>>> 616f688 (update backend')

  if (userRows.length === 0) {
    return res.status(400).json({ message: "Invalid user_id" });
  }

  try {
    const query = `INSERT INTO task (task_title, task_description, task_startTime, task_endTime, task_dateTime, user_user_id, task_role)
    VALUES (?, ?, ?, ?, ?, ?, ?)`;

    const values = [
      task_title,
      task_description,
      task_startTime,
      task_endTime,
      task_dateTime,
      user_id,
      "admin",
    ];
    const [taskResult] = await (await db).query(query, values);
    const taskId = taskResult.insertId;

    if (Array.isArray(plans) && plans.length > 0) {
      const planValues = plans.map((plan) => [
        taskId,
        plan.plan_detail,
        plan.plan_startTime,
        plan.plan_endTime,
      ]);

      const placeholders = planValues.map(() => "(?, ?, ?, ?)").join(", ");

      const flatValues = planValues.flat();

      await (
        await db
      ).query(
        `INSERT INTO plan (task_task_id, plan_detail, plan_startTime, plan_endTime) VALUES ${placeholders}`,
        flatValues
      );
    }

    for (let friendName of friend_name) {
<<<<<<< HEAD
=======
      console.log(friendName);
>>>>>>> 616f688 (update backend')
      const [friendResult] = await (
        await db
      ).query("select user_id from user where user_name=?", [friendName]);
      if (friendResult.length > 0) {
        const friend_id = friendResult[0].user_id;

        const [taskRequest] = await (
          await db
        ).query(
          "INSERT INTO taskRequest (user_user_id, user_sender_id, task_task_id, status) VALUES (?, ?, ?, ?)",
          [user_id, friend_id, taskId, "pending"]
        );

        await (
          await db
        ).query(
          "INSERT INTO notifications (notifications_type, notifications_action, user_user_id, user_sender_id, reference_id, reference_type) VALUES (?, ?, ?, ?, ?, ?)",
          [
            "task",
            "request",
            user_id,
            friend_id,
            taskRequest.insertId,
            "taskRequest",
          ]
        );

        await (
          await db
        ).query(
          "INSERT INTO notifications (notifications_type, notifications_action, user_user_id, user_sender_id, reference_id, reference_type) VALUES (?, ?, ?, ?, ?, ?)",
          [
            "task",
            "request",
            friend_id,
            user_id,
            taskRequest.insertId,
            "taskRequest",
          ]
        );
      }
    }

    return res.status(201).json({
      success: true,
      message: "Task and requests sent successfully",
      taskId,
    });
  } catch (err) {
    console.log(err);
    return res
      .status(500)
      .json({ success: false, message: "Error inserting task" });
  }
});

router.put("/update/:taskId", async (req, res) => {
  const {
    task_title,
    task_description,
    task_startTime,
    task_endTime,
    task_dateTime,
    user_id,
    friend_name,
    plans,
  } = req.body;
  const { taskId } = req.params;

  const [userRows] = await (
    await db
  ).query("SELECT user_id FROM user WHERE user_id = ?", [user_id]);

  if (userRows.length === 0) {
    return res.status(400).json({ message: "Invalid user_id" });
  }

  try {
    const [existingTask] = await (
      await db
    ).query("SELECT * FROM task WHERE task_id = ?", [taskId]);

    if (existingTask.length === 0) {
      return res.status(404).json({ message: "Task not found" });
    }

    const query = `
      UPDATE task 
      SET task_title = ?, task_description = ?, task_startTime = ?, 
          task_endTime = ?, task_dateTime = ?
      WHERE task_id = ?
    `;

    const values = [
      task_title || existingTask[0].task_title,
      task_description || existingTask[0].task_description,
      task_startTime || existingTask[0].task_startTime,
      task_endTime || existingTask[0].task_endTime,
      task_dateTime || existingTask[0].task_dateTime,
      taskId,
    ];

    await (await db).query(query, values);

    if (Array.isArray(plans) && plans.length > 0) {
      for (const plan of plans) {
        const { plan_id, plan_detail, plan_startTime, plan_endTime } = plan;

        const updatePlanQuery = `
          UPDATE plan
          SET plan_detail = ?, plan_startTime = ?, plan_endTime = ?
          WHERE plan_id = ? AND task_task_id = ?
        `;

        await (
          await db
        ).query(updatePlanQuery, [
          plan_detail,
          plan_startTime,
          plan_endTime,
          plan_id,
          taskId,
        ]);
      }
    } else {
      const planValues = plans.map((plan) => [
        taskId,
        plan.plan_detail,
        plan.plan_startTime,
        plan.plan_endTime,
      ]);

      const placeholders = planValues.map(() => "(?, ?, ?, ?)").join(", ");

      const flatValues = planValues.flat();

      await (
        await db
      ).query(
        `INSERT INTO plan (task_task_id, plan_detail, plan_startTime, plan_endTime) VALUES ${placeholders}`,
        flatValues
      );
    }

    for (let friendName of friend_name) {
      const [friendResult] = await (
        await db
      ).query("SELECT user_id FROM user WHERE user_name=?", [friendName]);

      if (friendResult.length > 0) {
        const friend_id = friendResult[0].user_id;

        const [taskRequest] = await (
          await db
        ).query(
          "INSERT INTO taskRequest (user_user_id, user_sender_id, task_task_id, status) VALUES (?, ?, ?, ?)",
          [user_id, friend_id, taskId, "pending"]
        );

        await (
          await db
        ).query(
          "INSERT INTO notifications (notifications_type, notifications_action, user_user_id, user_sender_id, reference_id, reference_type) VALUES (?, ?, ?, ?, ?, ?)",
          [
            "task",
            "request",
            user_id,
            friend_id,
            taskRequest.insertId,
            "taskRequest",
          ]
        );
      }
    }

    return res.status(200).json({
      success: true,
      message: "Task updated successfully",
      taskId,
    });
  } catch (err) {
    console.log(err);
    return res
      .status(500)
      .json({ success: false, message: "Error updating task" });
  }
});

router.get("/tasks/count", async (req, res) => {
  try {
    const query = `
      SELECT DATE_FORMAT(task_dateTime, '%Y-%m-%d') AS date, COUNT(*) AS task_count
      FROM task
      GROUP BY task_dateTime
      ORDER BY task_dateTime
    `;
    const [rows] = await (await db).query(query);
<<<<<<< HEAD
=======
    console.log(rows);
>>>>>>> 616f688 (update backend')
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error(err);
    res
      .status(500)
      .json({ success: false, error: "Failed to fetch task counts" });
  }
});

router.get("/categories", async (req, res) => {
  try {
    const [results] = await (await db).query("SELECT * FROM categorie");
    return res.status(200).json({
      success: true,
      data: results,
    });
  } catch (err) {
    return res
      .status(500)
      .json({ success: false, message: "Database query error" });
  }
});

router.get("/task/:task_id/participants", async (req, res) => {
  const task_id = req.params.task_id;

  const query = `
  SELECT u.user_name
    FROM participants p
    JOIN user u ON p.user_user_id = u.user_id
    WHERE p.task_task_id = ?
      AND p.participants_status = 'accepted'
      AND p.participants_role = 'participant'`;

  try {
    const [result] = await (await db).query(query, [task_id]);
    const [planResult] = await (
      await db
    ).query("SELECT * FROM plan where task_task_id=?", [task_id]);
    return res.json({ result, planResult });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ error: "Failed to fetch participants" });
  }
});

router.get("/searchFriends", async (req, res) => {
  const search = req.query.query.toLowerCase();

  try {
    const query = `SELECT * FROM user WHERE LOWER(user_name) LIKE ? OR LOWER(user_email) LIKE ?`;
    const [result] = await (
      await db
    ).query(query, [`%${search}%`, `%${search}`]);

    if (result.length > 0) {
      res.json(result);
    } else {
      res.status(404).json({ message: "No friends found" });
    }
  } catch (error) {
    console.error("Error searching friends: ", error);
    res.status(500).json({ error: "Failed to fetch friends" });
  }
});

router.post("/task", async (req, res) => {
  const { user_id, task_dateTime } = req.body;
  try {
    const [user] = await (
      await db
    ).query("Select * from user where user_id = ?", [user_id]);
    if (user.length === 0) {
      return res
        .status(401)
        .json({ success: false, message: "잘못된 로그인 정보입니다." });
    }
    const userId = user[0].user_id;
    const date = new Date(task_dateTime);
    const formattedDate = `${date.getFullYear()}-${
      date.getMonth() + 1
    }-${date.getDate()}`;

    const [results] = await (
      await db
    ).query("SELECT * FROM task where user_user_id=? and task_dateTime=? ", [
      userId,
      formattedDate,
    ]);

    return res.status(200).json({
      success: true,
      data: results,
    });
  } catch (err) {
    console.log(err);
    if (!res.headersSent) {
      return res
        .status(500)
        .json({ success: false, message: "서버 에러 발생" });
    }
  }
});

router.get("/notifications/:user_id", async (req, res) => {
  const { user_id } = req.params;

  const query = `
    SELECT n.notifications_id, n.notifications_type, n.notifications_action, n.notifications_status, n.notifications_createdAt, u.user_name AS sender_name, u.user_profile
    FROM notifications n
    JOIN user u ON n.user_sender_id = u.user_id
    WHERE n.user_user_id = ? OR n.user_sender_id=?
    ORDER BY n.notifications_createdAt DESC
  `;
  try {
    const [result] = await (await db).query(query, [user_id, user_id]);
    return res.json(result);
  } catch (error) {
    console.log(error);
    return res.status(500).json({ error: "Failed to fetch notifications" });
  }
});

// 보낸 친구 초대
router.get("/sentRequest/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const sent = await (
      await db
    ).query(
      `SELECT fs.friend_id, fs.status, u.user_name , fs.createdAt, fs.updatedAt, u.user_email
       FROM friendShips fs
       JOIN user u ON fs.friend_id = u.user_id
       WHERE fs.user_id = ? AND fs.status = ?`,
      [user_id, "pending"]
    );
    return res.status(200).json(sent);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// 받은 친구 초대
router.get("/receiveRequest/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const receive = await (
      await db
    ).query(
      `SELECT fs.user_id, fs.status, u.user_name, fs.createdAt, fs.updatedAt, u.user_email
       FROM friendShips fs
       JOIN user u ON fs.user_id = u.user_id
       WHERE fs.friend_id = ? AND fs.status = ?`,
      [user_id, "pending"]
    );
    return res.status(200).json(receive);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// 받은 요청 수락/거절
router.put("/response", async (req, res) => {
  const { user_id, friend_id, response } = req.body;
  try {
    const status = response === "accept" ? "accepted" : "rejected";
    await (
      await db
    ).query(
      "UPDATE friendShips SET status = ?, updatedAt = NOW() WHERE user_id =? AND friend_id=?",
      [status, friend_id, user_id]
    );

    const [notification] = await (
      await db
    ).query(
      "UPDATE notifications SET notifications_type = ?, notifications_action = ?, notifications_status = ? WHERE user_user_id = ? AND user_sender_id = ?",
      ["friends", "response", "unread", friend_id, user_id]
    );

    await (
      await db
    ).query(
      "UPDATE notifications SET notifications_type = ?, notifications_action = ?, notifications_status = ? WHERE user_user_id = ? AND user_sender_id = ?",
      ["friends", "response", "unread", user_id, friend_id]
    );

    return res.status(200).json({ notification });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/sentTask/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const sent = await (
      await db
    ).query(
      `SELECT tr.user_sender_id, tr.status, u.user_name, tr.created_at, tr.updated_at, u.user_email, t.task_title, t.task_dateTime
   FROM taskRequest tr
   JOIN user u ON tr.user_sender_id = u.user_id
   JOIN task t ON tr.task_task_id = t.task_id
   WHERE tr.user_user_id = ? AND tr.status = ? 
   ORDER BY tr.updated_at DESC`,
      [user_id, "pending"]
    );

    const task = await (await db).query("SELECT * FROM task");
    return res.status(200).json(sent);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/receiveTask/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const receive = await (
      await db
    ).query(
      `SELECT 
  tr.user_user_id, 
  tr.status,
  tr.task_task_id,
  u.user_name, 
  tr.created_at, 
  tr.updated_at, 
  u.user_email, 
  t.task_title
FROM 
  taskRequest tr
JOIN 
  user u 
ON 
  tr.user_user_id = u.user_id
JOIN 
  task t
ON 
  tr.task_task_id = t.task_id
WHERE 
  tr.user_sender_id = ? 
  AND tr.status = ?
  ORDER BY tr.updated_at DESC
`,
      [user_id, "pending"]
    );
    return res.status(200).json(receive);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.put("/responseTask", async (req, res) => {
  const { friend_id, response, user_id, task_id } = req.body;
  try {
    const status = response === "accept" ? "accepted" : "rejected";

    const [taskRequest] = await (
      await db
    ).query(
      "SELECT task_task_id FROM taskRequest WHERE task_task_id = ? AND (user_user_id = ? OR user_sender_id = ?)",
      [task_id, user_id, user_id]
    );
    const [task] = await (
      await db
    ).query(
      "SELECT task_role, user_user_id FROM task WHERE task_id=?",
      task_id
    );

    if (task[0].user_user_id !== user_id) {
      var role = "participant";
    } else {
      var role = "admin";
    }

    if (!taskRequest) {
      return res
        .status(404)
        .json({ message: "Task not found or you are not authorized." });
    }
    const { responseResult } = await (
      await db
    ).query(
      "UPDATE taskRequest SET status = ?, updated_at = NOW() WHERE task_task_id = ? AND user_user_id = ? AND user_sender_id = ?",
      [status, task_id, friend_id, user_id]
    );

    const [taskInfo] = await (
      await db
    ).query("SELECT * FROM task WHERE task_id =? ", task_id);
    if (response == "accept") {
      await (
        await db
      ).query(
        "INSERT INTO task (task_title, task_description, task_startTime, task_endTime, task_dateTime, categorie_categorie_id, user_user_id, task_role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        [
          taskInfo[0].task_title,
          taskInfo[0].task_description,
          taskInfo[0].task_startTime,
          taskInfo[0].task_endTime,
          taskInfo[0].task_dateTime,
          taskInfo[0].categorie_categorie_id,
          user_id,
          role,
        ]
      );
    }

    const [notification] = await (
      await db
    ).query(
      "UPDATE notifications SET notifications_type = ?, notifications_action = ?, notifications_status = ? WHERE user_user_id = ? AND user_sender_id = ?",
      ["task", "response", "unread", friend_id, user_id]
    );

    await (
      await db
    ).query(
      "UPDATE notifications SET notifications_type = ?, notifications_action = ?, notifications_status = ? WHERE user_user_id = ? AND user_sender_id = ?",
      ["task", "response", "unread", user_id, friend_id]
    );

    const [participant] = await (
      await db
    ).query(
      "INSERT INTO participant (user_user_id, task_task_id, status, role) VALUES(?, ?, ?, ?)",
      [user_id, task_id, "pending", role]
    );
    return res.status(200).json({ responseResult, notification, participant });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/search-member", async (req, res) => {
  const { email, user_id } = req.body;

  if (!email) {
    return res.status(400).json({ success: false, error: "Email is required" });
  }

  try {
    const [results] = await (
      await db
    ).query(
      "SELECT user_id, user_email, user_name FROM user WHERE user_email LIKE ? AND user_id != ?",
      [`%${email}%`, user_id]
    );

    const [userResult] = await (
      await db
    ).query("Select user_id from user where user_email =?", [email]);

    if (!userResult || userResult.length === 0) {
      return res.status(404).json({ error: "User not found with this email" });
    }

    const friend_id = userResult[0].user_id;

    const [existing] = await (
      await db
    ).query(
      "SELECT * FROM friendShips WHERE (user_id =? OR friend_id =?) AND (user_id=? OR friend_id=?)",
      [user_id, user_id, friend_id, friend_id]
    );

    if (results.length === 0) {
      return res.status(404).json({ success: false, error: "No users found" });
    }

    res.status(200).json({ success: true, data: results, existing });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: "Server error" });
  }
});

router.post("/friend-request", async (req, res) => {
  const { user_id, user_email } = req.body;

  try {
    const [userResult] = await (
      await db
    ).query("Select user_id from user where user_email =?", [user_email]);

    if (!userResult || userResult.length === 0) {
      return res.status(404).json({ error: "User not found with this email" });
    }

    const friend_id = userResult[0].user_id;

    const [existing] = await (
      await db
    ).query(
      "SELECT * FROM friendShips WHERE (user_id =? OR friend_id =?) AND (user_id=? OR friend_id=?) AND status != 'accepted'",
      [user_id, user_id, friend_id, friend_id]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        error: "Friend request already sent",
      });
    }

    const [result] = await (
      await db
    ).query(
      "INSERT INTO friendShips (user_id, friend_id, status) VALUES (?, ?, ?)",
      [user_id, friend_id, "pending"]
    );

    const [notication] = await (
      await db
    ).query(
      "INSERT INTO notifications (notifications_type, notifications_action, user_user_id, user_sender_id, reference_id, reference_type) VALUES (?, ?, ?, ?, ?, ?)",
      ["friends", "request", user_id, friend_id, result.insertId, "friendShip"]
    );

    await (
      await db
    ).query(
      "INSERT INTO notifications (notifications_type, notifications_action, user_user_id, user_sender_id, reference_id, reference_type) VALUES (?, ?, ?, ?, ?, ?)",
      ["friends", "request", friend_id, user_id, result.insertId, "friendShip"]
    );

    return res.status(201).json({
      success: true,
      message: "Friend request sent successfully",
      result,
      notication,
    });
  } catch (err) {
    console.log(err);
    return res.status(500).send({ error: "Error sending friend request" });
  }
});

router.post("/taskToday", async (req, res) => {
  const { user_id, task_dateTime } = req.body;
  try {
    const date = new Date(task_dateTime);
    const formatDate = `${date.getFullYear()}-${
      date.getMonth() + 1
    }-${date.getDate()}`;

    const [result] = await (
      await db
    ).query(
      "SELECT * FROM task WHERE task_dateTime >= CURDATE() AND user_user_id =? ORDER BY task_dateTime DESC",
      [user_id]
    );

    return res.status(200).json({
      success: true,
      data: result,
    });
  } catch (err) {
    console.log(err);
    return res.status(500).send({ error: "Error task today" });
  }
});

router.get("/available-friend/:task_id/:user_id", async (req, res) => {
  const { task_id, user_id } = req.params;

  if (!task_id || !user_id) {
    return res.status(400).json({ error: "Missing taskId or currentUserId" });
  }

  try {
    const query = `
  SELECT DISTINCT
    result.friend_id,
    u.user_name  
FROM (
    SELECT 
        CASE 
            WHEN fs.user_id = ? THEN fs.friend_id
            ELSE fs.user_id
        END AS friend_id
    FROM friendShips fs
    LEFT JOIN taskRequest tr
        ON (
            tr.user_user_id = CASE 
                WHEN fs.user_id = ? THEN fs.friend_id
                ELSE fs.user_id
            END
            AND tr.task_task_id = ?
        )
    LEFT JOIN user u
        ON u.user_id = CASE 
            WHEN fs.user_id = ? THEN fs.friend_id
            ELSE fs.user_id
        END
    WHERE 
        ? IN (fs.user_id, fs.friend_id)
        AND tr.user_user_id IS NULL
        AND fs.status = 'accepted' 
) AS result
LEFT JOIN user u 
    ON u.user_id = result.friend_id 
WHERE result.friend_id NOT IN (
    SELECT user_sender_id
    FROM taskRequest
    WHERE task_task_id = ?
);

`;

    const [friendResult] = await (
      await db
    ).query(query, [user_id, user_id, task_id, user_id, user_id, task_id]);

    const [taskResult] = await (
      await db
    ).query(
      `SELECT 
    tr.*, 
    u.user_name 
  FROM taskRequest tr
  JOIN user u ON tr.user_sender_id = u.user_id
  WHERE tr.task_task_id = ? AND tr.user_user_id = ?`,
      [task_id, user_id]
    );

    return res.status(200).json({ friendResult, taskResult });
  } catch (error) {
    console.error("Error fetching available friends:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/task-invitation", async (req, res) => {
  const { friend_name, user_id, task_id } = req.body;

  const [userRows] = await (
    await db
  ).query("SELECT user_id FROM user WHERE user_id = ?", [user_id]);

  if (userRows.length === 0) {
    return res.status(400).json({ message: "Invalid user_id" });
  }

  try {
    for (let friendName of friend_name) {
      const [friendResult] = await (
        await db
      ).query("select user_id from user where user_name=?", [friendName]);
      if (friendResult.length > 0) {
        const friend_id = friendResult[0].user_id;

        const [taskRequest] = await (
          await db
        ).query(
          "INSERT INTO taskRequest (user_user_id, user_sender_id, task_task_id, status) VALUES (?, ?, ?, ?)",
          [user_id, friend_id, task_id, "pending"]
        );

        await (
          await db
        ).query(
          "INSERT INTO notifications (notifications_type, notifications_action, user_user_id, user_sender_id, reference_id, reference_type) VALUES (?, ?, ?, ?, ?, ?)",
          [
            "task",
            "request",
            user_id,
            friend_id,
            taskRequest.insertId,
            "taskRequest",
          ]
        );
      }
    }

    return res.status(201).json({
      success: true,
      message: "Task and requests sent successfully",
      task_id,
    });
  } catch (err) {
    console.log(err);
    return res
      .status(500)
      .json({ success: false, message: "Error inserting task" });
  }
});

router.get("/user/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const [user] = await (
      await db
    ).query("SELECT * FROM user WHERE user_id=?", [user_id]);
    return res.status(200).json({ success: true, message: "successful", user });
  } catch (err) {
    console.log(err);
    return res
      .status(500)
      .json({ success: false, message: "Error user information" });
  }
});

router.post("/searchTask", async (req, res) => {
  const { query } = req.body;

  try {
    const sql = `
      SELECT t.*, 
       GROUP_CONCAT(u.user_name) AS participant_name, 
       GROUP_CONCAT(u.user_email) AS participant_email
FROM task t
LEFT JOIN participants p ON t.task_id = p.task_task_id
LEFT JOIN user u ON p.user_user_id = u.user_id
WHERE t.task_title LIKE ? 
   OR t.task_description LIKE ? 
   OR u.user_name LIKE ? 
   OR u.user_email LIKE ?
GROUP BY t.task_id, t.task_title, t.task_description, t.task_dateTime;

    `;

    const [result] = await (
      await db
    ).query(sql, [`%${query}%`, `%${query}%`, `%${query}%`, `%${query}%`]);

    if (result.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "No tasks found" });
    }

    return res.json({ success: true, tasks: result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});
router.post("/taskDate", async (req, res) => {
  const { date } = req.body;

  try {
    const query = `
      SELECT t.*, GROUP_CONCAT(u.user_name) AS participant_name, GROUP_CONCAT(u.user_email) AS participant_email
      FROM task t
      LEFT JOIN participants p ON t.task_id = p.task_task_id
      LEFT JOIN user u ON p.user_user_id = u.user_id
      WHERE DATE(task_dateTime) = ?
      GROUP BY t.task_id
    `;
    const [rows] = await (await db).query(query, [date]);

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No tasks found for the selected date",
      });
    }

    res.json({ success: true, tasks: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message });
  }
});

router.put(
  "/edit-user/:user_id",
  upload.single("profilePhoto"),
  async (req, res) => {
    const profilePhoto = req.file ? `/uploads/${req.file.filename}` : null;

    const { user_name, user_email, user_phone, user_gender, user_birthday } =
      req.body;
    const { user_id } = req.params;

    try {
      const query = `
      UPDATE user 
      SET 
        user_name = ?, 
        user_email = ?, 
        user_profile = ?, 
        user_phone = ?, 
        user_gender = ?, 
        user_birthday = ? 
      WHERE user_id = ?
    `;

      const [result] = await (
        await db
      ).query(query, [
        user_name,
        user_email,
        profilePhoto,
        user_phone,
        user_gender,
        user_birthday,
        user_id,
      ]);

      if (result.affectedRows === 0) {
        return res
          .status(404)
          .json({ success: false, message: "User not found" });
      }

      res
        .status(200)
        .json({ success: true, message: "Profile updated successfully" });
    } catch (err) {
      console.log(1);
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  }
);

router.put("/notifications/read", async (req, res) => {
  const { user_id, notification_type } = req.body;

  try {
    const result = await (
      await db
    ).query(
      "UPDATE notifications SET notifications_status = ? WHERE user_sender_id = ? AND notifications_status = ? AND notifications_type = ?",
      ["read", user_id, "unread", notification_type]
    );

    return res.status(200).json({ success: true, message: result });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

router.post("/request-password-reset", async (req, res) => {
  const { email } = req.body;

  try {
    const [rows] = await (
      await db
    ).query("SELECT * FROM user WHERE user_email = ?", [email]);
    if (rows.length === 0) {
      return res.status(404).json({ message: "사용자를 찾을 수 없습니다." });
    }

    const user = rows[0];

    const token = crypto.randomBytes(32).toString("hex");
    const expires = new Date(Date.now() + 3600000)
      .toISOString()
      .slice(0, 19)
      .replace("T", " ");

    await (
      await db
    ).query(
      "UPDATE user SET reset_token = ?, reset_token_expires = ? WHERE user_email = ?",
      [token, expires, email]
    );

    const transporter = nodemailer.createTransport({
      service: "Gmail",
      host: "smtp.gmail.com",
      port: 587,
      secure: true,
      auth: {
        type: "OAuth2",
        user: process.env.GMAIL_OAUTH_USER,
        clientId: process.env.GMAIL_OAUTH_CLIENT_ID,
        clientSecret: process.env.GAMIL_OAUTH_CLIENT_SECRET,
        refreshToken: process.env.GAMIL_OAUTH_REFRESH_TOKEN,
      },
      tls: {
        rejectUnauthorized: false,
      },
    });

    const resetLink = `http://10.0.2.2:8000/reset-password/${token}`;
    const mailOptions = {
      to: user.user_email,
      subject: "비밀번호 재설정 요청",
      text: `다음 링크를 통해 비밀번호를 재설정하세요: ${resetLink}`,
    };

    transporter.sendMail(mailOptions, (err, info) => {
      if (err) {
        console.error("Error occurred:", err);
        return;
      }
      console.log("Email sent:", info.response);
    });
    res.json({ message: "비밀번호 재설정 링크가 이메일로 전송되었습니다." });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "서버 오류가 발생했습니다." });
  }
});

router.post("/reset-password/:token", async (req, res) => {
  const { token } = req.params;
  const { newPassword } = req.body;

  try {
    const [rows] = await (
      await db
    ).query(
      "SELECT * FROM user WHERE reset_token = ? AND reset_token_expires > ?",
      [token, Date.now()]
    );

    if (rows.length === 0) {
      return res
        .status(400)
        .json({ message: "유효하지 않거나 만료된 토큰입니다." });
    }

    const user = rows[0];

    await (
      await db
    ).query(
      "UPDATE user SET user_password = ?, reset_token = NULL, reset_token_expires = NULL WHERE user_email = ?",
      [newPassword, user.user_email]
    );

    res.json({ message: "비밀번호가 성공적으로 변경되었습니다." });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "서버 오류가 발생했습니다." });
  }
});

module.exports = router;
