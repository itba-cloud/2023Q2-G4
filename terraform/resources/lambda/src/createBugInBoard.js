const { Client } = require('pg');

exports.handler = async (event, context) => {
    const dbConfig = {
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        password: process.env.DB_PASSWORD,
    };

    const response = {
        statusCode: 200,
        body: '',
    };

    let bugData;

    try {
        bugData = JSON.parse(event.body);
    } catch (error) {
        console.error('Error extracting bug data from the event body:', error);
        response.statusCode = 400;
        response.body = 'Invalid request body';
        return response;
    }

    const { name, description, due_by, stage, board_id } = bugData;

    if (!['icebox', 'to-do', 'doing', 'done'].includes(stage)) {
        console.error('Invalid stage:', stage);
        response.statusCode = 400; // Bad Request
        response.body = 'Invalid stage. Stage must be "icebox", "to-do", "doing", or "done"';
        return response;
    }

    const createBugQuery = {
        text: `
            INSERT INTO bugs (name, description, due_by, stage, board_id)
            VALUES ($1, $2, $3, $4, $5)
        `,
        values: [name, description, due_by, stage, board_id],
    };

    const client = new Client(dbConfig);

    try {
        console.log('Connecting to the database...');
        await client.connect();
        console.log('Connected to the database.');

        console.log('Executing the createBug query...');
        await client.query(createBugQuery);
        console.log('createBug query executed successfully.');

        console.log('Closing the database connection...');
        await client.end();
        console.log('Database connection closed.');

        response.body = 'Bug created';
    } catch (error) {
        console.error('Error creating bug:', error);
        response.statusCode = 500;
        response.body = 'Internal Server Error';
        return response;
    }

    return response;
};
