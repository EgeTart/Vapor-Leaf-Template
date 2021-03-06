import FluentSQLite
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    let serverConfiure = NIOServerConfig.default(hostname: "0.0.0.0", port: 9090)
    services.register(serverConfiure)
    
    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a SQLite database
    let databaseFilePath = NSHomeDirectory() + "/Documents/vapor/database/test.db"
    let sqlite = try SQLiteDatabase(storage: .file(path: databaseFilePath))
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .sqlite)
    services.register(migrations)
    
}
