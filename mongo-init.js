// MongoDB initialization script
// Creates the application database and user

db = db.getSiblingDB('evoagentx');

// Create application user with readWrite permissions
db.createUser({
  user: 'app_user',
  pwd: 'app_password',
  roles: [
    {
      role: 'readWrite',
      db: 'evoagentx'
    }
  ]
});

// Create collections with validation (optional)
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['username', 'email', 'hashed_password'],
      properties: {
        username: {
          bsonType: 'string',
          description: 'must be a string and is required'
        },
        email: {
          bsonType: 'string',
          pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
          description: 'must be a valid email address and is required'
        },
        hashed_password: {
          bsonType: 'string',
          description: 'must be a string and is required'
        },
        is_active: {
          bsonType: 'bool',
          description: 'must be a boolean'
        },
        is_superuser: {
          bsonType: 'bool',
          description: 'must be a boolean'
        },
        created_at: {
          bsonType: 'date',
          description: 'must be a date'
        },
        updated_at: {
          bsonType: 'date',
          description: 'must be a date'
        }
      }
    }
  }
});

db.createCollection('agents');
db.createCollection('workflows');
db.createCollection('executions');

// Create indexes
db.users.createIndex({ username: 1 }, { unique: true });
db.users.createIndex({ email: 1 }, { unique: true });
db.agents.createIndex({ name: 1 });
db.workflows.createIndex({ name: 1 });
db.executions.createIndex({ workflow_id: 1 });
db.executions.createIndex({ status: 1 });
db.executions.createIndex({ created_at: -1 });

print('MongoDB initialization completed successfully');