async function getCurrentUser(user) {
  return user; // already fetched in middleware
}

async function updateCurrentUser(user, updates) {
  Object.assign(user, updates);
  return await user.save();
}

module.exports = {
  getCurrentUser,
  updateCurrentUser,
};
