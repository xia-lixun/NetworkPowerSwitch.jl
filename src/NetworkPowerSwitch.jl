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
    client(to1, to2)

# Arguments
    - 'to1': time from turnoff-all to first conduct, for example 5 seconds
    - 'to2': time from turnoff-all to second conduct, for example 20 seconds
"""
function client(to1, to2, ip::IPv4=ip"192.168.1.199", port=12345)

    try
        # op = Array{String,1}()
        sock = connect(ip, port)

        write(sock, [0x41 0x54 0x0D 0x0A])
        status = readline(sock)
        # push!(op, "AT: $status")
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: AT $(status)")

        write(sock, [0x41 0x54 0x2B 0x4C 0x49 0x4E 0x4B 0x53 0x54 0x41 0x54 0x3D 0x3F 0x0D 0x0A])
        status = readline(sock)
        # push!(op, "AT+LINKSTAT: $status")
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: AT+LINKSTAT $(status)")
        
        write(sock, [0x41 0x54 0x2B 0x4D 0x4F 0x44 0x45 0x4C 0x3D 0x3F 0x0D 0x0A])
        status = readline(sock)
        # push!(op, "AT+MODEL: $status")
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: AT+MODEL: $(status)")

        strtemp = "Init Status: "
        write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x3F 0x0D 0x0A])
        for i = 1:4
            status = readline(sock)
            strtemp = strtemp * status
        end
        # push!(op, strtemp)
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: $(strtemp)")

        write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x30 0x0D 0x0A])
        status = readline(sock)
        # push!(op, "Turn off all switches: $status")
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: turn off all switches $(status) and wait for $(to1) seconds")
        sleep(to1)

        write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x31 0x3D 0x31 0x0D 0x0A])
        status = readline(sock)
        # push!(op, "Turn on switch 1: $status")
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: turn on switch 1 $(status) and wait for $(to2) seconds")
        sleep(to2)

        write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x32 0x3D 0x31 0x0D 0x0A])
        status = readline(sock)
        # push!(op, "Turn on switch 2: $status")
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: turn on switch 2 $(status)")
                
        strtemp = "Status: "
        write(sock, [0x41 0x54 0x2B 0x53 0x54 0x41 0x43 0x48 0x30 0x3D 0x3F 0x0D 0x0A])
        for i = 1:4
            status = readline(sock)
            strtemp = strtemp * status
        end
        # push!(op, strtemp)
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: $(strtemp)")
        close(sock)            
        Libaudio.printl("C:/Drivers/Julia/run.log", :green, Libaudio.nows() * " | NetworkPowerSwitch.client: power cycle complete")
        return true
    catch
        Libaudio.printl("C:/Drivers/Julia/run.log", :light_red, Libaudio.nows() * " | NetworkPowerSwitch.client: unknown error")
        return false
    end
end



end # module
