

WinEventBase::WinEventBase()
{

}

WinEventBase::~WinEventBase()
{

}

void WinEventBase::setCallback(std::function<void(WinEventBase*, int)> callback)
{
    callback_ = callback;
}

void WinCommEvent::handle_event(int flags)
{
    if (callback_) {
        callback_(this, flags);
    }
}
