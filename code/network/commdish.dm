// Any packet sent to #commdish will be received by any available comms dish.
// If a comms dish is cut, packets sent to #commdish may be dropped until
// the sender's DNS cache is flushed.

// NT's dishes are abstracted away - any message received by a dish is
// acted on as if it were received by NT.

/obj/machinery/commdish
	icon_state = "commdish"
	icon = 'icons/immibis/network_device.dmi'
	name = "communications dish"

	tdns_name = "commdish"

	networked = 1

	receive_packet(sender, packet)
		// All cross-space packets must be signed.
		var/sign_result = CheckPacketSignature(packet)
		if(!sign_result)
			return

		var/sig_id = sign_result[1]
		packet = sign_result[2]

		if(sig_id == "emshuttle")
			if(packet == "call")
				call_shuttle_proc()
			else if(packet == "recall")
				cancel_call_proc()