module NetworkPowerSwitch
using Sockets
using Libaudio

# Network Controlled Relay IP: 192.168.1.199:12345 (client)
# Host IP: 192.168.1.190:6000 (server)


"""
    server()

deprecated. use client function for better responsiveness.
"""
function server()
    op = Array{String,1}()
    #@async begin
        server = listen(IPv4(0), 6000)
        #while true
            sock = accept(server)
            write(sock, [0x41 0x54 0x0D 0x0A])
            status = readline(sock)
            push!(op, "AT: $status")

            write(sock, [0x41 0x54 0x2B 0x4C 0x49 0x4E 0x4B 0x53 0x54 0x41 0x54 0x3D 0x3F 0x0D 0x0A])
            status = readline(sock)
            push!(op, "AT+LINKSTAT: $status")
            write(sock, [0x41 0x54 0x2B 0x4D 0x4F 0x44 0x45 0x4C 0x3D 0x3F 0x0D 0x0A])
            status = readline(sock)
            push!(op, "AT+MODEL: $status")
            strtemp = "Init Status: "
            write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x3F 0x0D 0x0A])
            for i = 1:4
                status = readline(sock)
                strtemp = strtemp * status
            end
            push!(op, strtemp)
            write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x30 0x0D 0x0A])
            status = readline(sock)
            push!(op, "Turn off all switches: $status")
            sleep(5)
            write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x31 0x3D 0x31 0x0D 0x0A])
            status = readline(sock)
            push!(op, "Turn on switch 1: $status")
            sleep(20)
            write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x32 0x3D 0x31 0x0D 0x0A])
            status = readline(sock)
            push!(op, "Turn on switch 2: $status")
            strtemp = "Status: "
            write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x3F 0x0D 0x0A])
            for i = 1:4
                status = readline(sock)
                strtemp = strtemp * status
            end
            push!(op, strtemp)
            close(sock)            
        #end
    #end
    return op
end





"""
    npsopen(ip::IPv4=ip"192.168.1.199", port=12345)

open socket to nps

# Arguments
    - 'ip': IPv4 address of the remote switch
    - 'port': port number of the remote switch
"""
function npsopen(ip::IPv4=ip"192.168.1.199", port=12345)
    root = joinpath(Libaudio.folder(), Libaudio.logfile())
    sock = connect(ip, port)

    write(sock, [0x41 0x54 0x0D 0x0A])
    status = readline(sock)
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npsopen: AT $(status)")

    write(sock, [0x41 0x54 0x2B 0x4C 0x49 0x4E 0x4B 0x53 0x54 0x41 0x54 0x3D 0x3F 0x0D 0x0A])
    status = readline(sock)
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npsopen: AT+LINKSTAT $(status)")
    
    write(sock, [0x41 0x54 0x2B 0x4D 0x4F 0x44 0x45 0x4C 0x3D 0x3F 0x0D 0x0A])
    status = readline(sock)
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npsopen: AT+MODEL: $(status)")


    strtemp = "Init Status: "
    write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x3F 0x0D 0x0A])
    for i = 1:4
        status = readline(sock)
        strtemp = strtemp * status
    end
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npsopen: $(strtemp)")
    return sock
end




"""
    npsoff(sock)

turn off all switches
"""
function npsoff(sock)
    root = joinpath(Libaudio.folder(), Libaudio.logfile())
    write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x30 0x0D 0x0A])
    status = readline(sock)
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npsoff: turn off all switches $(status)")
    return nothing
end




"""
    npson(sock, i)

turn on i-th switch 
"""
function npson(sock, i=1)
    root = joinpath(Libaudio.folder(), Libaudio.logfile())
    pa = [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48]
    pb = [0x3D 0x31 0x0D 0x0A]
    write(sock, [pa convert(UInt8,0x30+i) pb])
    status = readline(sock)       
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npson: turn on switch $(i) $(status)")
    return nothing
end




"""
    npsclose(sock)

get the updated register states, close the socket and return true
"""
function npsclose(sock)
    root = joinpath(Libaudio.folder(), Libaudio.logfile())
    strtemp = "Updated Status: "
    write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x3F 0x0D 0x0A])
    for i = 1:4
        status = readline(sock)
        strtemp = strtemp * status
    end
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npsclose: $(strtemp)")
    close(sock)            
    Libaudio.printl(root, :green, Libaudio.nows() * " | NetworkPowerSwitch.npsclose: socket closed")
    return true
end




"""
    npserr()

if something is wrong return false
"""
function npserr()
    root = joinpath(Libaudio.folder(), Libaudio.logfile())
    Libaudio.printl(root, :light_red, Libaudio.nows() * " | NetworkPowerSwitch.npserr: unknown reason")
    return false
end




"""
    reboot(t, ip, port) where T <: Real

Turn off all switches and turn on each switch with time sequence specified.
# Arguments
    - 't': time between off and on 
           or visually, (all switches off)-->t[1]-->(switch 1 on)-->t[2]-->(switch 2 on)-->t[3]...
"""
function reboot(t::Array{T,1}) where T <: Real
    try
        nps = npsopen() 
        npsoff(nps)
        for (j,k) in enumerate(t)
            sleep(k)
            npson(nps, j)
        end
        npsclose(nps)
    catch
        npserr()
    end
end




"""
    alloff()

turn all switches off
"""
function alloff()
    try
        nps = npsopen()
        npsoff(nps)
        npsclose(nps)
    catch
        npserr()
    end
end


end # module
