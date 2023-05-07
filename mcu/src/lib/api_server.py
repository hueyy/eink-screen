# MicroDot does not support HTTPS and will throw a UnicodeError if
# accessed via HTTPS: https://github.com/miguelgrinberg/microdot/issues/62


def start_api_server():
    from microdot import Microdot, Request

    app = Microdot()

    Request.max_content_length = 2000 * 1024  # 2MB
    Request.max_body_length = 7 * 1024  # 7KB

    CORS_HEADERS = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "*",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Credentials": "true",
        "Access-Control-Max-Age": "86400",
    }

    CHUNK_SIZE = 1024  # 1KB

    @app.route("/")
    def index(request):
        return {"status": "OK"}

    @app.post("/clear/")
    def api_clear(request):
        from lib.display import Display

        d = Display()
        d.init_epd()
        d.clear()

        return {"status": "OK"}

    @app.route("/receive_data/", methods=["POST", "OPTIONS"])
    def api_receive_data(request):
        if not request.stream:
            return {"error": "body missing"}, 400

        content_length = int(request.headers["Content-Length"])
        if not (content_length > 0):
            return {"error": "body empty"}, 400

        from lib.display import Display

        d = Display()

        d.init_epd()
        while content_length > 0:
            chunk = request.stream.read(min(content_length, CHUNK_SIZE))
            d.epd.send_black_buffer(chunk)
            content_length -= len(chunk)
        d.epd.turn_on_display()
        return {"status": "OK"}, CORS_HEADERS

    @app.errorhandler(404)
    def not_found(request):
        return "Not found", 404

    @app.before_request
    def before_request(request):
        if request.method == "OPTIONS":
            res = Response(res)
            res.headers = res.headers | CORS_HEADERS
            return res

        import gc

        gc.collect()
        print("Memory free: ", gc.mem_free())

    print("Started HTTP server on port 80")
    app.run(port=80, debug=True)
