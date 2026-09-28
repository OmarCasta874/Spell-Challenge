SESSION_KEY = "mascot_msg"

def say(request, title, text=""):
    request.session[SESSION_KEY] = {"title": title, "text": text}
    
def mascot_context(request):
    if not hasattr(request, "session"):
        return {}
    return {"mascot_msg": request.session.pop(SESSION_KEY, None)}