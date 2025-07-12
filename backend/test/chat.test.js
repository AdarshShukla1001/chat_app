// tests/chat.test.js
const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../src/app');
const User = require('../src/users/user.model');
const Message = require('../src/chat/message.model');
const Group = require('../src/chat/group.model');
let mongoServer;
let token1, token2, user1, user2;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());

  // Register and login user1
  await request(app).post('/api/auth/signup').send({ name: 'User1', email: 'u1@test.com', password: 'pass123' });
  const res1 = await request(app).post('/api/auth/login').send({ email: 'u1@test.com', password: 'pass123' });
  token1 = res1.body.token;
  user1 = res1.body.user;

  // Register and login user2
  await request(app).post('/api/auth/signup').send({ name: 'User2', email: 'u2@test.com', password: 'pass123' });
  const res2 = await request(app).post('/api/auth/login').send({ email: 'u2@test.com', password: 'pass123' });
  token2 = res2.body.token;
  user2 = res2.body.user;
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('Chat Module - One-to-One and Group Messaging', () => {
  let groupId;

  it('should create one-to-one message and fetch messages', async () => {
    // Send one-to-one message
    const sendRes = await request(app)
      .get(`/api/chat/one-to-one/${user2._id}`)
      .set('Authorization', `Bearer ${token1}`);
    groupId = sendRes.body.groupId;

    expect(sendRes.statusCode).toBe(200);
    expect(Array.isArray(sendRes.body.messages)).toBe(true);

    const message = await Message.create({
      group: groupId,
      sender: user1._id,
      content: 'Hello from user1 to user2'
    });

    const fetchRes = await request(app)
      .get(`/api/chat/one-to-one/${user2._id}`)
      .set('Authorization', `Bearer ${token1}`);

    expect(fetchRes.body.messages.length).toBeGreaterThan(0);
  });

  it('should create a group and send group message', async () => {
    const groupRes = await request(app)
      .post('/api/chat/group')
      .set('Authorization', `Bearer ${token1}`)
      .send({ name: 'Test Group', participants: [user1._id, user2._id] });

    expect(groupRes.statusCode).toBe(201);
    const group = groupRes.body;

    const message = await Message.create({
      group: group._id,
      sender: user2._id,
      content: 'Hello group!' });

    const fetchRes = await request(app)
      .get(`/api/chat/group/${group._id}`)
      .set('Authorization', `Bearer ${token1}`);

    expect(fetchRes.statusCode).toBe(200);
    expect(fetchRes.body.length).toBeGreaterThan(0);
  });
});
